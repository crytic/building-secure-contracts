# Interacting with off-chain data using the `ffi` cheatcode

## Introduction

It is possible for Echidna to interact with off-chain data by means of the `ffi` cheatcode. This function allows the caller to execute an arbitrary command on the system running Echidna and read its output, enabling the possibility of getting external data into a fuzzing campaign.

## A word of caution

In general, the usage of cheatcodes is not encouraged, since manipulating the EVM execution environment can lead to unpredictable results and false positives or negatives in fuzzing tests.

This piece of advice becomes more critical when using `ffi`. This cheatcode basically allows arbitrary code execution on the host system, so it's not just the EVM execution environment that can be manipulated. Running malicious or untrusted tests with `ffi` can have disastrous consequences.

The usage of this cheatcode should be extremely limited, well documented, and only reserved for cases where there is not a secure alternative.

## Pre-requisites

If reading the previous section didn't scare you enough and you still want to use `ffi`, you will need to explicitly tell Echidna to allow the cheatcode in the tests. This safety measure makes sure you don't accidentally execute `ffi` code.

To enable the cheatcode, set the `allowFFI` flag to `true` in your Echidna configuration file:

```yaml
allowFFI: true
```

## Uses

Some of the use cases for `ffi` are:

- Making prices or other information available on-chain during a fuzzing campaign. For example, you can use `ffi` to feed an oracle with "live" data.
- Get randomness in a test. As you know, there is no randomness source on-chain, so using this cheatcode you can get a random value from the device running the fuzz tests.
- Integrate with algorithms not ported to Solidity language, or perform comparisons between two implementations. Some examples for this item include signing and hashing, or custom calculations algorithms.

## Example: Call an off-chain program and read its output

This example will show how to create a simple call to an external executable, passing some values as parameters, and read its output. Keep in mind that the return values of the called program should be an abi-encoded data chunk that can be later decoded via `abi.decode()`. No newlines are allowed in the return values.

Before digging into the example, there's something else to keep in mind: When interacting with external processes, you will need to convert from Solidity data types to string, to pass values as arguments to the off-chain executable. You can use the [crytic/properties](https://github.com/crytic/properties) `toString` [helpers](https://github.com/crytic/properties/blob/main/contracts/util/PropertiesHelper.sol#L447) for converting.

For the example we will be creating a python example script that returns a random `uint256` value and a `bytes32` hash calculated from an integer input value. This doesn't represent a "useful" use case, but will be enough to show how the `ffi` cheatcode is used. Finally, we won't perform sanity checks for data types or values, we will just assume the input data will be correct.

This script was tested with Python 3.11, Web3 6.0.0 and eth-abi 4.0.0. Some functions had different names in prior versions of the libraries.

```python
import sys
import secrets
from web3 import Web3
from eth_abi import encode

# Usage: python3 script.py number
number = int(sys.argv[1])

# Generate a 10-byte random number
random = int(secrets.token_hex(10), 16)

# Generate the keccak hash of the input value
hashed = Web3.solidity_keccak(['uint256'], [number])

# ABI-encode the output
abi_encoded = encode(['uint256', 'bytes32'], [random, hashed]).hex()

# Make sure that it doesn't print a newline character
print("0x" + abi_encoded, end="")
```

You can test this program with various inputs and see what the output is. If it works correctly, the program should output a 512-bit hex string that is the ABI-encoded representation of a 256-bit integer followed by a bytes32.

Now let's create the Solidity contract that will be run by Echidna to interact with the previous script.

```solidity
pragma solidity ^0.8.0;

// HEVM helper
import "@crytic/properties/contracts/util/Hevm.sol";

// Helpers to convert uint256 to string
import "@crytic/properties/contracts/util/PropertiesHelper.sol";

contract TestFFI {
    function test_ffi(uint256 number) public {
        // Prepare the array of executable and parameters
        string[] memory inp = new string[](3);
        inp[0] = "python3";
        inp[1] = "script.py";
        inp[2] = PropertiesLibString.toString(number);

        // Call the program outside the EVM environment
        bytes memory res = hevm.ffi(inp);

        // Decode the return values
        (uint256 random, bytes32 hashed) = abi.decode(res, (uint256, bytes32));

        // Make sure the return value is the expected
        bytes32 hashed_solidity = keccak256(abi.encodePacked(number));
        assert(hashed_solidity == hashed);
    }
}
```

The minimal configuration file for this test is the following:

```yaml
testMode: "assertion"
allowFFI: true
```
