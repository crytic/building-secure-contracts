# (Not So) Smart Contracts

This repository contains examples of common Ethereum smart contract vulnerabilities, including code from real smart contracts.
It also includes a repository and analysis of several [honeypots](honeypots/)

## Vulnerabilities

- [Bad randomness](bad_randomness/): Contract attempts to get on-chain randomness, which can be manipulated by users
- [Denial of Service](denial_of_service/): Attacker stalls contract execution by failing in strategic way
- [Incorrect Interface](incorrect_interface/): Implementation uses different function signatures than interface
- [Integer Overflow](integer_overflow/): Arithmetic in Solidity (or EVM) is not safe by default
- [Forced Ether Reception](forced_ether_reception/): Contracts can be forced to receive Ether
- [Missing Constructor](missing_constructor/): Anyone can become owner of contract due to missing constructor
- [Race Condition](race_condition/): Transactions can be frontrun on the blockchain
- [Reentrancy](reentrancy/): Calling external contracts gives them control over execution
- [Unchecked External Call](unchecked_external_call/): Some Solidity operations silently fail
- [Unprotected Function](unprotected_function/): Failure to use function modifier allows attacker to manipulate contract
- [Variable Shadowing](variable%20shadowing/): Local variable name is identical to one in outer scope

## Credits

These examples are developed and maintained by [Trail of Bits](https://www.trailofbits.com/). Contributions are encouraged and are covered under our [bounty program](https://github.com/trailofbits/not-so-smart-contracts/wiki#bounties).

If you have questions, problems, or just want to learn more, then join the #ethereum channel on the [Empire Hacking Slack](https://empireslacking.herokuapp.com/) or [contact us](https://www.trailofbits.com/contact/) directly.
