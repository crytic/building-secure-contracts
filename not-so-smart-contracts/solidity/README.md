
# (Not So) Smart Solidity Contracts

This repository contains examples of common Ethereum smart contract vulnerabilities, including code from real smart contracts. Use Not So Smart Contracts to
- learn about EVM and Solidity vulnerabilities
- as a reference when performing security reviews
- and as a benchmark for security and analysis tools.

## Features

Each _Not So Smart Contract_ includes a standard set of information:

* Description of the unique vulnerability type
* Attack scenarios to exploit the vulnerability
* Recommendations to eliminate or mitigate the vulnerability
* Real-world contracts that exhibit the flaw
* References to third-party resources with more information

## Vulnerabilities

| Not So Smart Contract | Description |
| --- | --- |
| [Bad randomness](bad_randomness) | Contract attempts to get on-chain randomness, which can be manipulated by users |
| [Dangerous Strict Equalities](dangerous_strict_equalities) | Use of strict equalities that can be easily manipulated by an attacker. |
| [Denial of Service](denial_of_service) | Attacker stalls contract execution by failing in strategic way |
| [Forced Ether Reception](forced_ether_reception) | Contracts can be forced to receive Ether |
| [Honeypots](honeypots) | Adversarial contracts that use obscure edge cases in a wide selection of solidity compiler versions to steal money from you when you think you're taking money from them |
| [Integer Overflow](integer_overflow) | Arithmetic in Solidity (or EVM) is not safe by default |
| [Race Condition](race_condition) | Transactions can be frontrun on the blockchain |
| [Reentrancy](reentrancy) | Calling external contracts gives them control over execution |
| [rtlo](rtlo) | Usage of malicious unicode character. |
| [Tautology](tautology) | Usage of always boolean expressions that are always true. |
| [Unprotected Function](unprotected_function) | Failure to use function modifier allows attacker to manipulate contract |
| [Unused Return Value ](unused-return) | Return values from calls that is not used. |


## Credits

These examples are developed and maintained by [Trail of Bits](https://www.trailofbits.com/). Contributions are encouraged and are covered under our [bounty program](https://github.com/trailofbits/not-so-smart-contracts/wiki#bounties).

If you have questions, problems, or just want to learn more, then join the #ethereum channel on the [Empire Hacking Slack](https://empireslacking.herokuapp.com/) or [contact us](https://www.trailofbits.com/contact/) directly.
