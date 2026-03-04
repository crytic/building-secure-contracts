# Counterfactual Wallet Vulnerability: Attacker Can Deploy a Wallet With Arbitrary EntryPoint

In **counterfactual wallet** setups, a user or dApp can generate a wallet address off-chain (before it's actually deployed on-chain), allowing them to receive funds in advance. Later, when needed, the user deploys the wallet code at that pre-generated address.  

However, if crucial parameters (like the wallet’s **entry point**) are **not** included in the deterministic address derivation (e.g., in the `salt` for `CREATE2`), an attacker can **front-run** the legitimate user’s deployment. By deploying the exact same counterfactual address but providing **their own** malicious entry point, the attacker gains control over that wallet. This lets them execute arbitrary calls—stealing funds or modifying ownership—before the real owner even deploys the wallet.

---

## How the Attack Works

1. **Counterfactual Address Generation**  
   - The project’s factory contract offers a function, e.g., `getAddressForCounterfactualWallet(owner, index)`, which uses `CREATE2` to compute a future wallet address based on `owner` and `index`.  
   - **Issue**: The computed address does **not** depend on the chosen `entryPoint`.

2. **User Funds the Future Address**  
   - Confident in the counterfactual design, the user (or others) sends ETH or tokens to the wallet’s predicted address **before** the wallet is deployed.

3. **Attacker Deploys First**  
   - Observing blockchain mempool or user behavior, the attacker calls the factory with the **same** `owner` and `index` but uses a **malicious** entry point.  
   - Because the derived wallet address only depends on `(owner, index)` and *not* the entry point, the resulting on-chain address is **the same** as the user’s counterfactual address.

4. **Malicious Entry Point**  
   - The attacker’s custom entry point (e.g., `StealEntryPoint`) gives them complete control to invoke privileged functions like `execFromEntryPoint`.  
   - They drain any ETH or tokens already at that address (or continue performing other malicious operations).

---

## Real-World Example

Below is a snippet from a reported issue on a **SmartAccountFactory** (part of the Biconomy codebase). It shows the factory’s `deployCounterFactualWallet` using a salt derived only from `_owner` and `_index`:

```solidity
function deployCounterFactualWallet(address _owner, address _entryPoint, address _handler, uint _index)
    public returns(address proxy)
{
    bytes32 salt = keccak256(abi.encodePacked(_owner, address(uint160(_index))));

    bytes memory deploymentData = abi.encodePacked(type(Proxy).creationCode, uint(uint160(_defaultImpl)));

    assembly {
        proxy := create2(0x0, add(0x20, deploymentData), mload(deploymentData), salt)
    }

    require(address(proxy) != address(0), "Create2 call failed");

    emit SmartAccountCreated(proxy, _defaultImpl, _owner, VERSION, _index);

    // The `_owner` is set here, but `_entryPoint` is not used in the salt for address derivation
    BaseSmartAccount(proxy).init(_owner, _entryPoint, _handler);

    isAccountExist[proxy] = true;
}
```