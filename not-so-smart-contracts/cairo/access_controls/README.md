# Access controls & account abstraction

The account abstraction model used by StarkNet has some important differences from what Solidity developers might be used to. There are no EOA addresses in StarkNet, only contract addresses. Rather than interact with contracts directly, users will usually deploy a contract that authenticates them and makes further calls on the user's behalf. At its simplest, this contract checks that the transaction is signed by the expected key, but it could also represent a multisig or DAO, or have more complex logic for what kinds of transactions it will allow (e.g. deposits and withdrawals could be handled by separate contracts or it could prevent unprofitable trades).

It is still possible to interact with contracts directly. But from the perspective of the contract, the caller's address will be 0. Since 0 is also the default value for uninitialized storage, it's possible to accidentally construct access control checks that fail open instead of properly restricting access to only the intended users.

## Attack Scenarios



## Mitigations

- Add zero address checks. Note that this will prevent users from interacting with the contract directly.

## Examples

- An [issue](https://github.com/OpenZeppelin/cairo-contracts/issues/148) in the ERC721 implementation included in a pre-0.1.0 version of OpenZeppelin's Cairo contract library would have allowed unapproved user to transfer tokens.