# Arbitrary CPI
Solana allows programs to call one another through cross-program invocation (CPI). This can be done via `invoke`, which is responsible for routing the passed in instruction to the program. Whenever an external contract is invoked via CPI, the program must check and verify the program ID. If the program ID isn't verified, then the contract can be called into an attacker-controlled contract instead of the intended one.

View ToB's lint implementation for the arbitrary CPI issue [here](https://github.com/crytic/solana-lints/tree/master/lints/arbitrary_cpi).

## Exploit Scenario

### Example Contract

## Mitigation
