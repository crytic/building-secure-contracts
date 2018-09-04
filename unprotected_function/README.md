# Unprotected function
Missing (or incorrectly used) modifier on a function allows an attacker to use sensitive functionality in the contract.

## Attack Scenario

A contract with a `changeOwner` function does not label it as `private` and therefore
allows anyone to become the contract owner.

## Mitigations

Always specify a modifier for functions.

## Examples
[Parity Wallet](https://blog.zeppelin.solutions/on-the-parity-wallet-multisig-hack-405a8c12e8f7). For code, see [initWallet](WalletLibrary_source_code/WalletLibrary.sol)

