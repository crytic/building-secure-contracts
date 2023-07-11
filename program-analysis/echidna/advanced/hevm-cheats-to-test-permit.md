# Using HEVM Cheats To Test Permit

## Introduction

[EIP 2612](https://eips.ethereum.org/EIPS/eip-2612) introduces the function `permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)` to the ERC20 ABI. This function takes in signature parameters generated through ECDSA, combined with the [EIP 712](https://eips.ethereum.org/EIPS/eip-712) standard for typed data hashing, and recovers the author of the signature through `ecrecover()`. It then sets `allowances[owner][spender]` to `value`.

## Uses

This method presents a new way of allocating allowances, as signatures can be computed off-chain and passed to a contract. It allows a relayer to pay the entire gas fee of the permit transaction in exchange for a fee, enabling completely gasless transactions for a user. Furthermore, this removes the typical `approve() -> transferFrom()` pattern that forces users to send two transactions instead of just one through this new method.

Note that for the permit function to work, a valid signature is needed. This example will demonstrate how we can use [`hevm`'s `sign` cheatcode](https://github.com/dapphub/dapptools/blob/master/src/hevm/README.md#cheat-codes) to sign data with a private key. More generally, you can use this cheatcode to test anything that requires valid signatures.

## Example

We use Solmate’s implementation of the ERC20 standard that includes the permit function. Observe that there are also values for the `PERMIT_TYPEHASH` and a `mapping(address -> uint256) public nonces`. The former is part of the EIP712 standard, and the latter is used to prevent signature replay attacks.

In our `TestDepositWithPermit` contract, we need to have the signature signed by an owner for validation. To accomplish this, we can use `hevm`’s `sign` cheatcode, which takes in a message and a private key and creates a valid signature. For this example, we use the private key `0x02`, and the following signed message representing the permit signature following the EIP 712:

```solidity
keccak256(
    abi.encodePacked(
        "\x19\x01",
        asset.DOMAIN_SEPARATOR(),
        keccak256(
            abi.encode(
                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                owner,
                spender,
                assetAmount,
                asset.nonces(owner),
                block.timestamp
            )
        )
    )
);
```

The helper function `getSignature(address owner, address spender, uint256 assetAmount)` returns a valid signature generated via the `sign` cheatcode. Note that the sign cheatcode exposes the private key, so it is best to use dummy keys when testing. Our keypair data was taken from [this site](https://privatekeys.pw/keys/ethereum/1). To test the signature, we will mint a random amount to the `OWNER` address, the address corresponding to the private key `0x02`, which was the signer of the permit signature. We then check whether we can use that signature to transfer the owner’s tokens to ourselves.

First, we call `permit()` on our Mock ERC20 token with the signature generated in `getSignature()`, and then call `transferFrom()`. If our permit request and transfer are successful, our balance of the mock ERC20 should increase by the amount permitted, and the `OWNER`'s balance should decrease as well. For simplicity, we'll transfer all the minted tokens so that the `OWNER`'s balance will be `0`, and our balance will be `amount`.

## Code

The complete example code can be found [here](https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/example/TestDepositWithPermit.sol).
