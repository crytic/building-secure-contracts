# Paymaster Deposit Drain via Signature Replay

Paymasters that do not track used signatures can have their deposits drained through repeated submission.

## Description

Verifying paymasters validate UserOperations by checking that a trusted signer produced the paymaster signature. If the paymaster's `getHash` function omits the account nonce, the same paymaster signature remains valid across different UserOperations with different nonces. Each submission deducts gas costs from the paymaster's EntryPoint deposit.

The EntryPoint enforces sequential nonces on the account, so the attacker cannot submit the exact same operation twice. However, if the paymaster's signature does not cover the nonce, the attacker can construct new UserOperations with incrementing nonces that all pass paymaster validation using the original signature. Each operation consumes gas from the paymaster's deposit while the attacker pays nothing.

## Exploit Scenario

Alice obtains a paymaster signature whose `getHash` does not include the account nonce. She submits a UserOperation with nonce 0 that the paymaster sponsors. She then submits new UserOperations with nonces 1, 2, 3, etc., each reusing the same paymaster signature. Each passes validation because the signature covers the same fields regardless of nonce. After 100 submissions, the paymaster's deposit is drained.

## Example

```solidity
contract VulnerablePaymaster is BasePaymaster {
    address public verifyingSigner;

    function _validatePaymasterUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 maxCost
    ) internal view override returns (bytes memory context, uint256 validationData) {
        bytes32 hash = getHash(userOp);
        address signer = ECDSA.recover(hash, userOp.paymasterAndData[20:]);

        // No tracking of used hashes
        require(signer == verifyingSigner, "invalid signature");
        return (abi.encode(userOp.sender), 0);
    }
}
```

## Mitigations

- Track used signature hashes in a `mapping(bytes32 => bool)` and reject duplicates.
- Include the wallet's current nonce in the paymaster signature hash.
- Enforce per-wallet spending limits over time windows.
- Use time-bounded validity windows (`validAfter` / `validUntil`) to limit signature lifetime.
