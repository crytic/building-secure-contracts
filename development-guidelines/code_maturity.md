# Blockchain Maturity Evaluation

- Document version: 0.1.0

This document provides criteria for developers and security engineers to use when evaluating a codebase’s maturity. Deficiencies identified during this evaluation often stem from root causes within the software development life cycle that should be addressed through standardization or training and awareness programs. This document aims to push the industry towards higher quality requirements and to reduce risks associated with immature practices, such as the introduction of bugs, a broken development cycle, and technical debt.

The document can be used as a self-evaluation protocol for developers, or as an evaluation guideline for security engineers.

As technologies and tooling improve, standards and best practices evolve, and this document will be updated to reflect such progress. We invite the community to open [issues](https://github.com/crytic/building-secure-contracts/issues) to provide insights and feedback and to regularly revisit this document for new versions.

- [Blockchain Maturity Evaluation](#blockchain-maturity-evaluation)
  - [Rating system](#rating-system)
  - [Arithmetic](#arithmetic)
  - [Auditing](#auditing)
  - [Authentication / access controls](#authentication--access-controls)
  - [Complexity management](#complexity-management)
  - [Decentralization](#decentralization)
  - [Documentation](#documentation)
  - [Transaction ordering risks](#transaction-ordering-risks)
  - [Low-level manipulation](#low-level-manipulation)
  - [Testing and verification](#testing-and-verification)

## Rating system

This Codebase Maturity Evaluation uses five ratings:

- **Missing**: Not present / not implemented
- **Weak**: Several and/or significant areas of improvement have been identified.
- **Moderate**: The codebase follows adequate procedure, but it can be improved.
- **Satisfactory**: The codebase is above average, but it can be improved.
- **Strong**: Only small potential areas of improvement have been identified.

_How are ratings determined?_ While the process for assigning ratings can vary due to a number of variables unique to each codebase (e.g., use cases, size and complexity of the codebase, specific goals of the audit, timeline), a general approach for determining ratings is as follows:

- If “Weak” criteria apply, “Weak” is applied.
- If _none_ of the “Weak” criteria apply, and some “Moderate” criteria apply, “Moderate” can be applied.
- If _all_ “Moderate” criteria apply, and some “Satisfactory” criteria apply, “Satisfactory” can be applied.
- If _all_ “Satisfactory” criteria apply, and there is evidence of exceptional practices or security controls in place, “Strong” can be applied.

## Arithmetic

### Weak <!-- omit from toc -->

A weak arithmetic maturity reflects the lack of a systematic approach toward ensuring the correctness of the operations and reducing the risks of arithmetic-related flaws such as overflow, rounding, precision loss, and trapping. Specific criteria include, but are not limited to, the following:

- No explicit overflow protection (e.g., Solidity 0.8 or SafeMath) is used, and no justification for the lack of protection exists.
- Intentional usage of unchecked arithmetic is not sufficiently documented.
- There is no specification of the arithmetic formulas, or the specification does not match the code.
- No explicit testing strategy has been identified to increase confidence in the system’s arithmetic.
- The testing does not cover critical—or several—arithmetic edge cases.

### Moderate <!-- omit from toc -->

This rating indicates that the codebase follows best practices, but lacks a systematic approach toward ensuring the correctness of the arithmetic operations. The code is well structured to facilitate the testing of operations, and multiple testing techniques are used. Specific criteria include, but are not limited to, the following:

- None of the weak criteria apply to the codebase.
- Unchecked arithmetics are minimal and justified, and extra documentation has been provided.
- All overflow and underflow risks are documented and tested.
- Explicit rounding up or down is used for all operations that lead to precision loss.
- All rounding risks are documented and described in the specification.
- An automated testing technique is used for arithmetic-related code (e.g., fuzzing, formal methods).
- Arithmetic operations are structured through stateless functions to facilitate their testing.
- System parameters are bounded, the ranges are explained, and their impacts are propagated through the documentation/specification.

### Satisfactory <!-- omit from toc -->

Arithmetic-related risks are clearly identified and understood. A theoretical analysis ensures that the code is consistent with the specification. Specific criteria include, but are not limited to, the following:
The system meets all moderate criteria.

- Precision loss is analyzed against a ground-truth (e.g, using an infinite-precision arithmetic library), and the loss is bounded and documented.
- All trapping operations (overflow protection, divide by zero, etc.) and their impacts are identified and documented.
- The arithmetic specification is a one-to-one match with the codebase. Each formula relevant to the white paper/specification has a respective function that is easily identifiable.
- The automated testing technique(s) cover all significant arithmetic operations and are run periodically, or ideally in the CI.

## Auditing

“Auditing” refers to the proper use of events and monitoring procedures within the system.

### Weak <!-- omit from toc -->

The system has no strategy towards emitting or using events. Specific criteria include, but are not limited to, the following:

- Events are missing for critical components updates.
- There are no clear or consistent guidelines for event-emitting functions.
- The same events are reused for different purposes.

### Moderate <!-- omit from toc -->

The system is built to be monitored. An off-chain infrastructure for detecting unexpected behavior is in place, and the team can be notified about events. Clear documentation highlights how the events should be used by third parties. Specific criteria include, but are not limited to, the following:

- None of the weak criteria apply to the codebase.
- Events are emitted for all critical functions.
- There is an off-chain monitoring system that logs events, and a monitoring plan has been implemented.
- The monitoring documentation describes the purpose of events, how events should be used, and their assumptions.
- The monitoring documentation describes how to review logs in order to audit a failure.
- An [incident response plan](https://github.com/crytic/building-secure-contracts/blob/master/development-guidelines/incident_response.md) describes how the protocol’s actors must react in case of failure.

### Satisfactory <!-- omit from toc -->

The system is well monitored, and processes are in place to react in case of defect or failure. Specific criteria include, but are not limited to, the following:
The system meets all moderate criteria.

- The off-chain monitoring system triggers notifications and/or alarms if unexpected behavior or events occur.
- Well-defined roles and responsibilities are defined for cases where unexpected behavior or vulnerabilities are detected.
- The incident response plan is regularly tested through a cybersecurity incident response exercise.

## Authentication / access controls

“Authentication / access controls” refers to the use of robust access controls to handle identification and authorization and to ensure safe interactions with the system.

### Weak <!-- omit from toc -->

The expected access controls are unclear or inconsistent; one address may be in control of the entire system, and there is no indication of additional safeguards for this account. Specific criteria include, but are not limited to, the following:
No access controls are in place for privileged functions, or some privileged functions lack access controls.

- There are no differentiated privileged actors or roles.
- All privileged functions are callable by one address, and there is no indication that this address will have further access controls (e.g., multisig).

### Moderate <!-- omit from toc -->

The system adheres to best practices, the major actors are documented and tested, and risks are limited through a clear separation of privileges. Specific criteria include, but are not limited to, the following:
None of the weak criteria apply to the codebase.

- All privileged functions have some form of access control.
- The principle of [least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege) is followed for all components.
- There are different roles in the system, and privileges for different roles do not overlap.
- There is clear documentation about the actors and their respective privileges in the system.
- Tests cover every actor-specific privilege.
- Roles can be revoked (if applicable).
- Two-step processes are used for privileged operations performed by Externally Owned Accounts (EOA).

### Satisfactory <!-- omit from toc -->

All actors and roles are clearly documented, including their expected privileges, and the implementation is consistent with all expected behavior and thoroughly tested. All known risks are highlighted and visible to users. Specific criteria include, but are not limited to, the following:

- The system meets all moderate criteria.
- All actors and roles are well documented.
- Actors with privileges are not EOAs.
- Leakage or loss of keys from one signer or actor does not compromise the system or affect other roles.
- Privileged functions are tested against known attack vectors.

## Complexity management

“Complexity management” refers to the separation of logic into functions with a clear purpose. The presence of clear structures designed to manage system complexity, including the separation of system logic into clearly defined functions, is the central focus when evaluating the system with respect to this category.

### Weak <!-- omit from toc -->

The code has unnecessary complexity (e.g., failure to adhere to well-established software development practices) that hinders automated and/or manual review. Specific criteria include, but are not limited to, the following:

- Functions overuse nested operations (if/then/else, ternary operators, etc.).
- Functions have unclear scope, or their scope include too many components.
- Functions have unnecessary redundant code/code duplication.
- Contracts have a complex inheritance tree.

### Moderate <!-- omit from toc -->

The most complex parts of the codebase are well identified, and their complexity is reduced as much as possible. Specific criteria include, but are not limited to, the following:
None of the weak criteria apply to the codebase.

- Functions have a high cyclomatic complexity ([≥11](https://en.wikipedia.org/wiki/Cyclomatic_complexity#Interpretation)).
- Critical functions are well scoped, making them easy to understand and test.
- Redundant code in the system is limited and justified.
- Inputs and their expected values are clear, and validation is performed where necessary.
- A clear and documented naming convention is in place for functions, variables, and other identifiers, and the codebase clearly adheres to the convention.
- Types are not used to enforce correctness.

## Satisfactory <!-- omit from toc -->

The code has little or no unnecessary complexity, any necessary complexity is well documented, and all code is easy to test. Specific criteria include, but are not limited to, the following:

- The system meets all moderate criteria.
- Each function has a specific and clear purpose and is clearly documented.
- Core functions are straightforward to test via unit tests or automated testing.
- There is no redundant behavior.

## Decentralization

“Decentralization” refers to the presence of a decentralized governance structure for mitigating insider threats and managing risks posed by privileged actors. Decentralization is not required to have a mature smart contract codebase, and a project that does not claim to be decentralized might not fit within this category. However, if a single point of failure exists, it must be clearly identified and proper protections must be put in place.

> A note on upgradeability: Upgradeability is often an important feature to consider when reviewing the decentralization of a system. While upgradeability is not, at a fundamental or theoretical level, incompatible with decentralization, it is, in practice, an obstacle in realizing robust system decentralization. Upgradeable systems that aim to be decentralized have additional requirements to demonstrate that their upgradeable components do not impact their decentralization.

## Weak <!-- omit from toc -->

The system has several points of centrality that may not be clearly visible to the users. Specific criteria include, but are not limited to, the following:

- Critical functionalities are upgradable by a single entity (e.g., EOA, multisig, DAO), and an arbitrary user cannot opt out from the upgrade or exit the system before the upgrade is triggered.
- A single entity is in direct control of user funds.
- All decision making is controlled by a single entity.
- System parameters can be changed at any time by a single entity.
- Permission/authorization by a centralized actor is required to use the contracts.

## Moderate <!-- omit from toc -->

Centralization risks are identified, justified and documented, and users might choose to not follow an upgrade. Specific criteria include, but are not limited to, the following:

- None of the weak criteria apply to the codebase.
- Risks related to trusted parties (if any) are clearly documented.
- Users have a documented path to opt out of upgrades or exit the system, or upgradeability is present only for non-critical features.
- Privileged actors are not able to unilaterally move funds out of, or trap funds in, the protocol.
- All privileges are documented.

## Satisfactory <!-- omit from toc -->

The system provides clear justification to demonstrate its path toward decentralization. Specific criteria include, but are not limited to the following:

- The system meets all moderate criteria.
- The system does not rely on on-chain voting for critical updates, or it is demonstrated that the on-chain voting does not have centralization risks. On-chain voting systems tend to have hidden centralized points and require careful consideration.
- Deployment risks are documented.
- Risks related to external contract interactions are documented.
- The critical configuration parameters are immutable once deployed, or the users have a documented path to opt out of the changes or exit the system if they are updated.

## Documentation

“Documentation” refers to the presence of comprehensive and readable codebase documentation, including inline code comments, the roles and responsibilities of system entities, system invariants, use cases, expected system behavior, and data flow diagrams.

### Weak <!-- omit from toc -->

Minimal documentation is present, or documentation is clearly incomplete or outdated. Specific criteria include, but are not limited to, the following:

- There is only a high-level description of the system.
- Code comments do not match the documentation.
- Documentation is not publicly available. (Note that this applies only to codebases meant for general public usage.)
- Documentation depends directly on a set of artificial terms or words that are not clearly explained.

### Moderate <!-- omit from toc -->

The documentation adheres to best practices. Important components are documented; the documentation exists at different levels (such as inline code comments, NatSpec, and system documentation); and there is consistency across all documentation. Specific criteria include, but are not limited to, the following:

- None of the weak criteria apply to the codebase.
- Documentation is written in a clear manner, and the language is not ambiguous.
- A glossary of terms exists for business-specific words and phrases.
- The architecture is documented through diagrams or similar constructs.
- Documentation includes user stories.
- Documentation clearly identifies core/critical components, such as those that significantly affect the system and/or its users.
- Reading documentation is sufficient to understand the expected behavior of the system without delving into specific implementation details.
- All critical functions are documented.
- All critical code blocks are documented.
- Known risks and system limitations are documented.

### Satisfactory <!-- omit from toc -->

Thorough documentation exists spanning all of the areas required for a moderate rating, as well as system corner cases, detailed aspects of users stories, and all features. The documentation matches the code. Specific criteria include, but are not limited to, the following:

- The system meets all moderate criteria.
- The user stories cover all user operations.
- There are detailed descriptions of the expected system behaviors.
- The implementation is consistent with the specification; if there are deviations from the specification, they are strongly justified, thoroughly explained, and reasonable.
- Function and system invariants are clearly defined in the documentation.
- Consistent naming conventions are followed throughout the codebase and documentation.
- There is specific documentation for end-users and for developers.

## Transaction ordering risks

“Transaction ordering risks” refers to the resilience against malicious ordering of the transactions. This includes toxic forms of Miner Extractable Value (MEV), such as front-running, sandwiching, forced liquidations, and oracle attacks.

### Weak <!-- omit from toc -->

There are unexpected/undocumented risks that arise due to the ordering of transactions. Specific criteria include, but are not limited to, the following:

- Transaction ordering risks are not clearly identified or documented.
- Protocols or user assets are at risk of unexpected transaction ordering.
- The system relies on unjustified constraints to prevent MEV extraction.
- The system makes unproven assumptions about which attributes may or may not be manipulatable by an MEV extractor.

### Moderate <!-- omit from toc -->

Risks related to transaction ordering are identified and, when applicable, limited through on-chain mitigations. Specific criteria include, but are not limited to, the following:

- None of the weak criteria apply to the codebase.
- Transaction ordering risks related to user operations are limited, justified, and documented.
- If MEV is inherent to the protocol, reasonable mitigations, such as time delays and slippage checks, are in place.
- The testing strategy emphasizes transaction ordering risks.
- The system uses tamper-resistant oracles.

### Satisfactory <!-- omit from toc -->

All transaction ordering risks are documented and clearly justified. The known risks are highlighted through documentation and tests and are visible to the users. Specific criteria include, but are not limited to, the following:

- The system meets all moderate criteria.
- The documentation centralizes all known MEV opportunities.
- Transactions ordering risks on privileged operations (e.g., system updates) are limited, justified, and documented.
- Known transaction ordering opportunities have tests highlighting the underlying risks.

## Low-level manipulation

“Low-level manipulation” refers to the usage of low-level operations (e.g., assembly code, bitwise operations, low-level calls) and relevant justification within the codebase.

### Weak <!-- omit from toc -->

The code uses unjustified low-level manipulations. Specific criteria include, but are not limited to, the following:

- Usage of assembly code or low-level manipulation is not justified; most can likely be replaced by high-level code.

### Moderate <!-- omit from toc -->

Low level operations are justified and limited. Extra documentation and testing is provided for them. Specific criteria include, but are not limited to, the following:

- None of the weak criteria apply to the codebase.
- Use of assembly code is limited and justified.
- Inline code comments are present for each assembly operation.
- The code does not re-implement well-established, low-level library functionality without justification (e.g., OZ’s SafeERC20).
- A high-level implementation reference exists for each function with complex assembly code.

### Satisfactory <!-- omit from toc -->

Thorough documentation, justification, and testing exists to increase confidence in all usage of assembly code and low-level manipulation. Implementations are validated with automated testing against a reference implementation. Specific criteria include, but are not limited to, the following:

- The system meets all moderate criteria.
- Differential fuzzing, or a similar technique, is used to compare the high-level reference implementation against its low level counterpart.
- Risks related to compiler optimization or experimental features are identified and justified.

## Testing and verification

“Testing and verification” refers to the robustness of testing procedures of techniques (including unit tests, integration tests, fuzzing, and symbolic execution) as well as the amount of test coverage.

### Weak <!-- omit from toc -->

Testing is limited and covers only some of the “happy paths.” Specific criteria include, but are not limited to, the following:

- Common or expected use cases are not fully tested.
- Provided tests fail for the codebase.
- There is insufficient or non-existent documentation to run the test suite “out of the box.”

### Moderate <!-- omit from toc -->

Testing adheres to best practices and covers a large majority of the code. An automated testing technique is used to increase the confidence of the most critical components. Specific criteria include, but are not limited to, the following:

- None of the weak criteria apply to the codebase.
- Most functions, including normal use cases, are tested.
- All provided tests for the codebase pass.
- Code coverage is used for the unit tests, and the report is easy to retrieve.
- An automated testing technique is used for critical components.
- Testing is implemented as part of the CI/CD pipeline.
- Integration tests are implemented, if applicable.
- Test code follows best practices and does not trigger warnings by the compiler or static analysis tools.

### Satisfactory <!-- omit from toc -->

Testing is clearly an important part of codebase development. Tests include unit tests and end-to-end testing. Code properties are clearly identified and validated with an automated testing technique. Specific criteria include, but are not limited to, the following:

- The system meets all moderate criteria.
- The codebase reaches 100% of reachable branch and statement coverage in unit tests.
- An end-to-end automated testing technique is used and all users' entry points are covered.
- Test cases are isolated and do not depend on each other or on the execution order, unless justified.
- Mutant testing is used to detect missing or incorrect tests/properties.
