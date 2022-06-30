# Incorrect Signers

In Cosmos, transaction's signature(s) are validated against public keys (addresses) taken from the transaction itself,
where locations of the keys [are specified in a `GetSigners` method](https://docs.cosmos.network/master/core/transactions.html#signing-transactions).

In the simples case there is just one signer required, and its address is simple to use correctly.
However, in more complex scenarios like when multiple signatures are required or a delegation schema is implemented,
it is possible to make mistake about what addresses in the transaction (message) are actually authenticated. 

Fortunately, mistakes in `GetSigners` should make part of application's intended functionality not working,
making it easy to spot the bug.  

## Example 

The `incorrect_getsigners` application allows an author to create posts and, moreover, to delegate the job to other users
(so they can create posts in author's name).

Start a testchain with `ignite chain serve`, CLI with `ignite chain build`, and then

* Use `Alice` account to create an example post
    ```sh
    incorrect_getsignersd tx incorrectgetsigners create-post foo bar --from alice
    ```

* Set delegation to `Bob` (so Bob could create content as the Alice)
    ```sh
    export bob=$(incorrect_getsignersd  keys show bob -a)
    export alice=$(incorrect_getsignersd  keys show alice -a)
    incorrect_getsignersd tx incorrectgetsigners delegate $bob --from alice
    ```

* Use `Bob` account to create a new post in the name of Alice 
    ```sh
    incorrect_getsignersd tx incorrectgetsigners delegate-post $alice another posssst --from bob
    ```
  
It will fail.

## Attack Scenarios

On the other hand, malicious users are able to impersonate authors:
```sh
incorrect_getsignersd keys add eve
incorrect_getsignersd tx incorrectgetsigners delegate $alice --from eve
incorrect_getsignersd tx incorrectgetsigners delegate-post $alice evail pooost --from eve
incorrect_getsignersd q incorrectgetsigners delegations && incorrect_getsignersd q incorrectgetsigners posts
```

## Mitigations

- Keep signers-related logic simple
- Implement tests for all functionalities 

