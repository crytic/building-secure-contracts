# Incorrect Signers

In Cosmos, transaction's signature(s) are validated against public keys (addresses) taken from the transaction itself,
where locations of the keys [are specified in `GetSigners` methods](https://docs.cosmos.network/v0.46/core/transactions.html#signing-transactions).

In the simplest case there is just one signer required, and its address is simple to use correctly.
However, in more complex scenarios like when multiple signatures are required or a delegation schema is implemented,
it is possible to make mistakes about what addresses in the transaction (the message) are actually authenticated. 

Fortunately, mistakes in `GetSigners` should make part of application's intended functionality not working,
making it easy to spot the bug.  

## Example 

The `incorrect_getsigners` application allows an author to create posts.

The `MsgCreatePost` message has `signer` and `author` fields. The first one is used for signature verification (as can be seen in `GetSigners` method), while the later is saved along with the post's content.

This bug allows users to impersonate other users by sending an arbitrary `author` field.

## Mitigations

- Keep signers-related logic simple
- Implement basic sanity tests for all functionalities

