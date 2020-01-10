## Determining Properties


### Thread modeling
To efficiently test and verify your code, you must identify the areas that need attention. As your resources spent on security are limited, scoping the weak or the high-value parts of your codebase is primordial to optimize the effort spent. Threat modeling will help you. There are many threat modeling frameworks, consider reading:
- [Guide to Data-Centric System Threat Modeling](https://csrc.nist.gov/publications/detail/sp/800-154/draft) (aka NIST 800-154)
- [Shostack thread modeling](https://www.amazon.com/Threat-Modeling-Designing-Adam-Shostack/dp/1118809998)
- [STRIDE](https://en.wikipedia.org/wiki/STRIDE_(security)) / [DREAD](https://en.wikipedia.org/wiki/DREAD_(risk_assessment_model))
- [PASTA](https://en.wikipedia.org/wiki/Threat_model#P.A.S.T.A.)
- [RRA](https://infosec.mozilla.org/guidelines/risk/rapid_risk_assessment.html)

### Componenents

Knowing what you want to check will also help you to select the right tool.

The components to be tested, that are frequently relevant for smart contracts, include:

- **State machine.** Most of the contracts can be represented partially as a state machine. Some general properties to test:
   + No invalid state can be reached.
   + If a state is valid, then it can be reached.
   + There are no terminal states (where other states cannot be reached).
  - Echidna and Manticore are the tools to favor to test state-machines specifications.

- **Access control.** If you system has privileged users (e.g. an owner, controllers, …) you must ensure that (1) each user can only perform the authorized actions and (2) no user can block actions from a more priviledged one.
  - Slither, Echidna and Manticore can be used to check the correct access control. For example, Slither can check that only whitelisted functions don’t have the modifier onlyOwner. Echidna and Manticore will be useful in case of more complex access control, such as a permission given only if the contract reaches a given state.

- **Arithmetic operations.** Checking the soundness of the arithmetic operations is critical. Using `SafeMath` everywhere is a good step to prevent overflow/underflow, but you must consider all the other arithmetic flaws, including rounding issues and flaws trapping the contract.
  - Manticore is the best choice here. Echidna can be used if the arithmetic is out-of-scope of the SMT solver.

- **Inheritance correctness.** Solidity-based contracts rely heavily on multiple inheritance. Mistakes such as a shadowing function missing a `super` call, or misinterpreted  c3 linearization order can easily be introduced.
  - Slither is the tool to ensure to be detect this kind of issue.

- **External interactions.** Contracts interact with each others, and some external contracts should not be trusted. For example, if your contract relies on external oracles, should it be robust if less than half of the oracles are compromised?
  - Manticore and Echidna will allow to test the external interactions. Manticore has an inbuilt mechanism to stub external contracts.

- **Standard conformance.** Ethereum standards (e.g. ERC20) have a history of flaws in their design. Be sure to be aware of the limitations of the standard you are building on top of.
  - Slither will let you detect the standard used to detect potential issues. Echidna and Manticore can be also be used to test for standard properties, but requiere to careful implement each ERC property. 

To summarize:

Component | Tools | Examples
--- | --- | --- |
State machine | Echidna, Manticore | 
Access control | Slither, Echidna, Manticore | [Slither exercise 2](https://github.com/trailofbits/building-secure-contracts/blob/master/program-analysis/slither/exercise2.md), [Echidna exercise 2](https://github.com/trailofbits/building-secure-contracts/blob/master/program-analysis/echidna/Exercise-2.md)
Arithmetic operations | Manticore, Echidna | [Echidna exercise 1](https://github.com/trailofbits/building-secure-contracts/blob/master/program-analysis/echidna/Exercise-1.md), [Manticore exercises 1 - 3](https://github.com/trailofbits/building-secure-contracts/tree/master/program-analysis/manticore/exercises)
Inheritance correctness | Slither | [Slither exercise 1](https://github.com/trailofbits/building-secure-contracts/blob/master/program-analysis/slither/exercise1.md)
External interactions | Manticore, Echidna | 
Standard conformance | Slither | [`slither-erc`](https://github.com/crytic/slither/wiki/ERC-Conformance)

Depending on your application's goal, other areas will need to be checked.

Some of our public audits contain examples of properties verified or tested. Consider reading the section `Automated Testing and Verification` of the [0x](https://github.com/trailofbits/publications/blob/master/reviews/0x-protocol.pdf) audit to see properties written on a real-world codebase.
