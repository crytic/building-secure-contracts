# Integer overflow 1

## Principle
- Integer overflow possible on the function `add`

## Attack
Once a first call have be made on `add` or `safe_add`, a call to `add` can trigger an integer overflow
