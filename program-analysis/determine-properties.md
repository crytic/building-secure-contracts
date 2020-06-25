## Determining Security Properties

### Threat modeling

To efficiently test and verify your code, you must identify the areas that need attention. As your resources spent on security are limited, scoping the weak or high-value parts of your codebase is important to optimize your effort. Threat modeling will help you. There are many threat modeling frameworks, consider reading:

- [Rapid Risk Assessments](https://infosec.mozilla.org/guidelines/risk/rapid_risk_assessment.html) (our preferred approach when time is short)
- [Guide to Data-Centric System Threat Modeling](https://csrc.nist.gov/publications/detail/sp/800-154/draft) (aka NIST 800-154)
- [Shostack thread modeling](https://www.amazon.com/Threat-Modeling-Designing-Adam-Shostack/dp/1118809998)
- [STRIDE](https://en.wikipedia.org/wiki/STRIDE_(security)) / [DREAD](https://en.wikipedia.org/wiki/DREAD_(risk_assessment_model))
- [PASTA](https://en.wikipedia.org/wiki/Threat_model#P.A.S.T.A.)

### Components

Knowing what you want to check will also help you to select the right tool.

The components to be tested, that are frequently relevant for smart contracts, include:

- **State machine.** Most contracts can be represented as a state machine. Consider checking that (1) No invalid state can be reached, (2) if a state is valid that it can be reached, and (3) no state traps the contract.
  - Echidna and Manticore are the tools to favor to test state-machines specifications.

- **Access control.** If you system has privileged users (e.g. an owner, controllers, ...) you must ensure that (1) each user can only perform the authorized actions and (2) no user can block actions from a more priviledged user.
  - Slither, Echidna and Manticore can check for correct access controls. For example, Slither can check that only whitelisted functions lack the onlyOwner modifier. Echidna and Manticore are useful for more complex access control, such as a permission given only if the contract reaches a given state.

- **Arithmetic operations.** Checking the soundness of the arithmetic operations is critical. Using `SafeMath` everywhere is a good step to prevent overflow/underflow, however, you must still consider other arithmetic flaws, including rounding issues and flaws that trap the contract.
  - Manticore is the best choice here. Echidna can be used if the arithmetic is out-of-scope of the SMT solver.

- **Inheritance correctness.** Solidity contracts rely heavily on multiple inheritance. Mistakes such as a shadowing function missing a `super` call and misinterpreted c3 linearization order can easily be introduced.
  - Slither is the tool to ensure detection of these issues.

- **External interactions.** Contracts interact with each other, and some external contracts should not be trusted. For example, if your contract relies on external oracles, will it remain secure if half the available oracles are compromised?
  - Manticore and Echidna are the best choice for testing external interactions with your contracts. Manticore has an built-in mechanism to stub external contracts.

- **Standard conformance.** Ethereum standards (e.g. ERC20) have a history of flaws in their design. Be aware of the limitations of the standard you are building on.
  - Slither, Echidna, and Manticore will help you to detect deviations from a given standard. 

To summarize:

Component | Tools | Examples
--- | --- | --- |
State machine | Echidna, Manticore | 
Access control | Slither, Echidna, Manticore | [Slither exercise 2](https://github.com/trailofbits/building-secure-contracts/blob/master/program-analysis/slither/exercise2.md), [Echidna exercise 2](https://github.com/trailofbits/building-secure-contracts/blob/master/program-analysis/echidna/Exercise-2.md)
Arithmetic operations | Manticore, Echidna | [Echidna exercise 1](https://github.com/trailofbits/building-secure-contracts/blob/master/program-analysis/echidna/Exercise-1.md), [Manticore exercises 1 - 3](https://github.com/trailofbits/building-secure-contracts/tree/master/program-analysis/manticore/exercises)
Inheritance correctness | Slither | [Slither exercise 1](https://github.com/trailofbits/building-secure-contracts/blob/master/program-analysis/slither/exercise1.md)
External interactions | Manticore, Echidna | 
Standard conformance | Slither, Echidna, Manticore | [`slither-erc`](https://github.com/crytic/slither/wiki/ERC-Conformance)

Other areas will need to be checked depending on your goals, but these coarse-grained areas of focus are a good start for any smart contract system.

Our public audits contain examples of verified or tested properties. Consider reading the `Automated Testing and Verification` sections of the following reports to review real-world security properties:

- [0x](https://github.com/trailofbits/publications/blob/master/reviews/0x-protocol.pdf)
- [Balancer](https://github.com/trailofbits/publications/blob/master/reviews/BalancerCore.pdf)
