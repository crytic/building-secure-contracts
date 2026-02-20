# Account Creation Frontrunning

CREATE2 salts that do not bind the owner allow attackers to frontrun account deployment and steal funds.

## Description

Smart account factories use CREATE2 for deterministic address derivation, allowing users to receive funds before the account is deployed. The predicted address is computed from the factory address, the bytecode hash, and a salt. If the salt does not cryptographically bind the intended owner, an attacker who observes the creation transaction in the mempool can frontrun it with a different owner but the same salt.

The account deploys at the expected address because the salt and bytecode are identical, but the owner is now the attacker. Any funds previously sent to the predicted address become immediately accessible to the attacker. This is especially dangerous because the pre-funding pattern is standard practice in ERC-4337 workflows where users send ETH to their future account address before the first UserOperation triggers deployment.

## Exploit Scenario

Alice uses the factory to compute her future account address with salt `42`. She receives 10 ETH at this predicted address. When she broadcasts the `createAccount` transaction, Bob observes it in the mempool and frontruns with `createAccount(bobAddress, 42)`. The account deploys at Alice's predicted address with Bob as owner. Bob calls `execute` to withdraw Alice's 10 ETH.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableFactory {
    // All accounts deploy the same proxy bytecode — owner is set via initialize()
    bytes public constant PROXY_BYTECODE = type(AccountProxy).creationCode;

    function createAccount(
        address owner,
        uint256 salt
    ) external returns (address) {
        // BUG: salt does not incorporate the owner — same salt = same address regardless of owner
        address account = Create2.deploy(0, bytes32(salt), PROXY_BYTECODE);
        AccountProxy(account).initialize(owner);
        return account;
    }

    function getAddress(uint256 salt) public view returns (address) {
        return Create2.computeAddress(bytes32(salt), keccak256(PROXY_BYTECODE));
    }
}
```

## Mitigations

- Embed the owner address in the CREATE2 salt (e.g., `salt = keccak256(abi.encode(owner, userSalt))`).
- Verify that the deployed account's owner matches the caller or a committed value.
- Do not send ETH to predicted addresses until the account is deployed and ownership is confirmed.
- Use `msg.sender` as part of the salt to bind deployment to a specific EOA.
