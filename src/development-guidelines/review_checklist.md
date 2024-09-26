# How to prepare for a security review

Get ready for your security review! Ensuring a few key elements are in place before the review starts can make the process significantly smoother for both sides.

## Set a goal for the review

This is the most important step of a security review, and paradoxically the one most often overlooked. You should have an idea of what kind of questions you want answered, such as:

- What’s the overall level of security for this product?
- What are the areas that you are the most concerns about?
  - Take into considerations previous audits and issues, complex parts, and fragile components.
- What is the worst case scenario for your project?

Knowing your biggest area of concern will help the assessment team tailor their approach to meet your needs.

## Resolve the easy issues

Handing the code off to the assessment team is a lot like releasing the product: the cleaner the code, the better everything will go. To that end:

- **Triage all results from static analysis tools**. Go after the low-hanging fruits and use:
  - [Slither](https://github.com/crytic/slither) for Solidity codebases
  - [dylint](https://github.com/trailofbits/dylint) for Rust codebases
  - [golangci](https://golangci-lint.run/) for Go codebases
  - [CodeQL and Semgrep](https://appsec.guide/) for Go/Rust/C++/... codebases
- **Increase unit and feature test coverage**. Ideally this has been part of the development process, but everyone slips up, tests don’t get updated, or new features don’t quite match the old integrations tests. Now is the time to update the tests and run them all.
- **Remove dead code, unused libraries, and other extraneous weight.** You may know which is unused but the consultants won’t and will waste time investigating it for potential issues. The same goes for that new feature that hasn’t seen progress in months, or that third-party library that doesn’t get used anymore.

## Ensure the code is accessible

Making the code accessible and clearly identified will avoid wasting ressources from the security engineers.

- **Provide a detailed list of files for review.**. This will avoid confusion if your codebase is large and some elements are not meant to be in scope.
- **Create a clear set of build instructions, and confirm the setup by cloning and testing your repository on a fresh environment.** A code that cannot be built is a code more difficult to review.
- **Freeze a stable commit hash, branch, or release prior to review.** Working on a moving target makes the review more difficult
- **Identify boilerplates, dependencies and difference from forked code**. By highliting what code you wrote, you will help keeping the review focused

## Document, Document, Document

Streamline the revuew process of building a mental model of your codebase by providing comprehensive documentation.

- **Create flowcharts and sequence diagrams to depict primary workflows**. They will help identify the components and their relationships
- **Write users stories**. Having users stories is a powerful tool to explain a project
- **Outline the on-chain / off-chain assumptions**. This includes:
  - Data validation procedure
  - Oracles information
  - Bridges assumptions
- **List actors and with their respective roles and privileges**. The complexity of a system grows with its number of actors.
- **Incorporate external developer documentation that links directly to your code**. This will help to ensure the documentation is up to date with the code
- **Add function documentation and inline comments for complex areas of your system**. Code documentation should include:
  - System and function level invariants
  - Parameter ranges (minimum and maximum values) used in your system.
  - Arithmetic formula: how they map to their specification, and their precision loss exceptations
- **Compile a glossary for consistent terminology use.** You use your codebase every day and you are familar with the terminology - a new person looking at your code is not
- **Consider creating short video walkthroughs for complex workflows or areas of concern**. Video walkthroughs is a great format to share your knowledge
