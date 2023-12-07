# Security Review Preparation Checklist

So, you're getting a security review! 

Ensure the security review proceeds smoothly by taking prior action with the following informative items.

## Essential Items 
The items below guide us in focusing effectively on the pertinent parts of your code, maximizing our utilization of time and resources.

- [ ] **Provide build instructions** – share how to build and test your code using a fresh clone of your repository. It gives us direct insight into your setup.
- [ ] **List exact files in scope for the review** –  list out the exact files to be reviewed to focus on key areas of your codebase.
- [ ] **Freeze and share your hash/branch/release before the review starts** – a stable commit allows us to start digging into your codebase and learning how it works. Tell your security review team what commit to review, and try to ensure that this commit is frozen before the review commences. 
- [ ] **Add inline comments** –  utilise comments on complex areas of the codebase. Document why something was done, its purpose and goal. 
- [ ] **Provide Natspec documentation** – ensure all functions have NatSpec descriptions for function's purpose, parameters, and return values.
- [ ] **Provide test coverage report** – provide a report outlining tested and untested code areas.
- [ ] **Share your unit tests** – share your unit tests with us! We may use it to understand the system flow, can provide feedback on its setup, and can use it to test proof of concepts. 
- [ ] **List external dependencies you're using and their purpose** – list used libraries and external dependencies along with their purposes.
- [ ] **Create user flow diagrams** – outline the entrypoint functions, subsequent callstacks, and expected system interactions for users.
- [ ] **Design an architecture diagram** – illustrate the interactions among contracts.
- [ ] **Let us know what you're worried about** – reveal parts of the code or exploit paths that cause concern.This helps us target our review and make sure that we prioritize the areas of the codebase you're worried about.
- [ ] **Document the impossible** – know when you are making assumptions on types and their values into the codebase, and document all these instances. 

### Defi-Specific Additions  
- [ ] **Share economic analysis performed on the codebase** – sharing results of economic analysis will help us to understand the boundaries of inputs and ranges of outputs.
- [ ] **List system invariants** – define your assumptions about system operations and function behaviors.
- [ ] **Provide documentation for arithmetic formulas used with code references** – all formulas you implement should be referenced in this document, with a link to the function in your code that implements it. If the representation in your code differs from the formula, provide the derivation that maps the formula used in the code and the formula you intend to implement. 
- [ ] **Create a glossary for your system** – consistently used terminology should be documented and made accessible.
- [ ] **Validation of rounding directions** – share all analysis you have done on checking the correct rounding direction for your system. 

### Bridge-Specific Additions
- [ ] **Document off-chain checks** – provide details about validations performed by off-chain components like relayers or bots.
- [ ] **Checks performed by off-chain components such as relayers or bots** tell us what data validation takes place off-chain so we can better understand what data is sent to smart contracts 
- [ ] **Transition of value-passing on source and destination chains** – show us how the chains share data, and what return values/emissions from a source chain maps to a destination chain 

## Beneficial Additions

Providing the following items can bolster the efficiency of our review, allowing for a deeper and more thorough examination of your codebase.

- [ ] **Ranges of all system parameters used in the system** – explicitly outline the minimum and maximum bound of configuration values in your codebase 
- [ ] **Document all design decisions** – decision-making processes engineering tradeoffs, and discarded alternatives related to the system and codebase setup provides valuable context that greatly enhances our review efficiency, affording a more comprehensive and nuanced understanding of the entire system.  
- [ ] **Provide results of fuzz and differential testing** – especially vital if your code involves lower-level assembly or math-related libraries. This aids us in employing tooling to spot deviations and edge cases.
- [ ] **Perform and report on stateful invariant testing** – such testing enables us to pinpoint edge cases that might occur during end-to-end operations.
- [ ] **Provide videos of complex workflows** – visual aids can effectively capture complex workflows, improving our grasp of the system's intricacies and bolstering the efficiency of our review.
- [ ] **Provide lists of actors with their expected roles and privileges** – outlining the distinct actors in your system, along with their specific roles and permissions, grants us a clearer understanding of how user interactions are designed and how authority is structured within the system. This, in turn, boosts the efficiency and depth of our review.
- [ ] **Prepare and share an Incident response plan** – a robust incident response plan provides insight into how your system is prepared to handle potential security breaches or unexpected system behavior. By sharing this, we can assess the system's robustness under adverse conditions, as well as provide recommendations for enhancing the resilience of your incident response strategy.

### References 

- Our own experience 
- [The Pragamatic Programmer](https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/)