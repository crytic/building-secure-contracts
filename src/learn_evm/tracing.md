# Tracing Utils

## Transaction Tracing

One excellent way to learn more about the internal workings of the EVM is to trace the execution of a transaction opcode by opcode. This approach can also help you assess the correctness of assembly code and catch problems related to the compiler or its optimization steps.

The following JavaScript snippet uses an `ethers` provider to connect to an Ethereum node with the `debug` JSON RPC endpoints activated. Although this requires an archive node on Mainnet, it can also be run quickly and easily against a local development Testnet using Hardhat node, Ganache, or some other Ethprovider targeting developers.

Transaction traces for even simple smart contract interactions are verbose, so we recommend providing a filename to save the trace for further analysis. Note that the following function depends on the `fs` module built into Node.js, so it should be copied into a Node console rather than a browser console. However, the filesystem interactions could be removed for use in the browser.

```
const ethers = require("ethers");
const fs = require("fs");

const provider = new ethers.providers.JsonRpcProvider(
  process.env.ETH_PROVIDER || "http://localhost:8545"
);

let traceTx = async (txHash, filename) => {
  await provider.send("debug_traceTransaction", [txHash]).then((res) => {
    console.log(`Got a response with keys: ${Object.keys(res)}`);
    const indexedRes = {
      ...res,
      structLogs: res.structLogs.map((structLog, index) => ({
        index,
        ...structLog,
      })),
    };
    if (filename) {
      fs.writeFileSync(filename, JSON.stringify(indexedRes, null, 2));
    } else {
      log(indexedRes);
    }
  });
};
```

By default, transaction traces do not feature a sequential index, making it difficult to answer questions such as, "Which was the 100th opcode executed?" The above script adds such an index for easier navigation and communication.

The output of the script contains a list of opcode executions. A snippet might look something like:

```
{
  "structLogs": [
    ...,
    {
      "index": 191,
      "pc": 3645,
      "op": "SSTORE",
      "gas": 10125,
      "gasCost": 2900,
      "depth": 1,
      "stack": [
        "0xa9059cbb",
        "0x700",
        "0x7fb610713c8404e21676c01c271bb662df6eb63c",
        "0x1d8b64f4775be40000",
        "0x0",
        "0x1e01",
        "0x68e224065325c640131672779181a2f2d1324c4d",
        "0x7fb610713c8404e21676c01c271bb662df6eb63c",
        "0x1d8b64f4775be40000",
        "0x0",
        "0x14af3e50252dfc40000",
        "0x14af3e50252dfc40000",
        "0x7d7d4dc7c32ad4c905ab39fc25c4323c4a85e4b1b17a396514e6b88ee8b814e8"
      ],
      "memory": [
        "00000000000000000000000068e224065325c640131672779181a2f2d1324c4d",
        "0000000000000000000000000000000000000000000000000000000000000002",
        "0000000000000000000000000000000000000000000000000000000000000080"
      ],
      "storage": {
        "7d7d4dc7c32ad4c905ab39fc25c4323c4a85e4b1b17a396514e6b88ee8b814e8": "00000000000000000000000000000000000000000000014af3e50252dfc40000"
      }
    },
    ...,
  ],
  "gas": 34718,
  "failed": false,
  "returnValue": "0000000000000000000000000000000000000000000000000000000000000001"
}
```

An overview of the fields for opcode execution trace:

- `index`: The index we added indicates that the above opcode was the 191st one executed. This is helpful for staying oriented as you jump around the trace.
- `pc`: Program counter, for example, this opcode exists at index `3645` of the contract bytecode. You will notice that `pc` increments by one for many common opcodes, by more than one for PUSH opcodes, and is reset entirely by JUMP/JUMP opcodes.
- `op`: Name of the opcode. Since most of the actual data is hex-encoded, using grep or ctrl-f to search through the trace for opcode names is an effective strategy.
- `gas`: Remaining gas _before_ the opcode is executed
- `gasCost`: Cost of this operation. For CALL and similar opcodes, this cost takes into account all gas spent by the child execution frame.
- `depth`: Each call creates a new child execution frame, and this variable tracks how many sub-frames exist. Generally, CALL opcodes increase the depth and RETURN opcodes decrease it.
- `stack`: A snapshot of the entire stack _before_ the opcode executes
- `memory`: A snapshot of the entire memory _before_ the opcode executes
- `storage`: An accumulation of all state changes made during the execution of the transaction being traced

Navigating a transaction trace can be challenging, especially when trying to match opcode executions to higher-level Solidity code. An effective first step is to identify uncommon opcodes that correspond to easily identifiable logic in the source code. Generally, expensive operations are relatively uncommon, so SLOAD and SSTORE are good ones to scan first and match against places where state variables are read or written in Solidity. Alternatively, CALL and related opcodes are relatively uncommon and can be matched with calls to other contracts in the source code.

If there is a specific part of the source code you are interested in tracing, matching uncommon opcodes to the source code will give you bounds on where to search. From this point, you will likely start walking through the trace opcode by opcode as you review the source code line by line. Leaving a few ephemeral comments in the source code, like `# opcode 191`, can help you keep track and pick up where you left off if you need to take a break.

Exploring transaction traces is challenging work, but the reward is an ultra-high-definition view of how the EVM operates internally and can help you identify problems that might not be apparent from just the source code.

## Storage Tracing

Although you can get an overview of all the changes to the contract state by checking the `storage` field of the last executed opcode in the above trace, the following helper function will extract that for you for quicker and easier analysis. If you are conducting a more involved investigation into a contract's state, we recommend you check out the [`slither-read-storage`](https://blog.trailofbits.com/2022/07/28/shedding-smart-contract-storage-with-slither/) command for a more powerful tool.

```
const traceStorage = async (txHash) => {
  await provider.send("debug_traceTransaction", [txHash]).then((res) => {
    log(res.structLogs[res.structLogs.length - 1].storage);
  });
};
```
