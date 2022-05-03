# State modifications in a view function

StarkNet provides the @view decorator to signal that a function should not make state modifications. However, this is [not currently enforced by the compiler](https://starknet.io/docs/hello_starknet/intro.html). Developers should take care when designing view functions but also when calling functions in other contracts as they may result in unexpected behavior if they do include state modifications accidentally.

## Attack Scenarios



## Mitigations

- Carefully review all `@view` functions, including those called in 3rd party contracts, to ensure they don't modify state unexpectedly.

## Examples
