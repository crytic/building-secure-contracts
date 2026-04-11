# Preparing for a Security Review

A security review is most effective when the codebase is well-organized, documented, and free of trivial issues. This checklist helps teams maximize the value of their security engagement by resolving surface-level problems beforehand, allowing reviewers to focus on deep, application-specific vulnerabilities.

Based on the [Trail of Bits guide](https://blog.trailofbits.com/2018/04/06/how-to-prepare-for-a-security-audit/) with blockchain-specific additions.

## Define the scope and goals

- [ ] **Identify the specific questions you want answered.** Examples: What is the overall security posture? Can users access other users' data? Can an attacker drain funds from the protocol?
- [ ] **Communicate your biggest area of concern to the review team.** Tailor the engagement so reviewers prioritize the most critical components.
- [ ] **Provide a clear description of the system's architecture.** Include diagrams showing contract interactions, external dependencies, and trust boundaries.

## Resolve the easy issues

- [ ] **Enable and address all compiler warnings.** Upgrade to the latest stable compiler version and fix every warning. For Solidity, use the latest `0.8.x` release.
- [ ] **Run [Slither](https://github.com/crytic/slither) and address all findings.** Document any required setup steps or configuration. Fix or explicitly acknowledge each detector output. See the [Slither documentation](../program-analysis/slither).
- [ ] **Increase unit and integration test coverage.** Update tests to reflect current behavior and integrations. Aim for full branch coverage on critical paths.
- [ ] **Remove dead code, unused variables, stale branches, and unused libraries.** Extraneous code wastes reviewer time and increases attack surface.
- [ ] **Document any incomplete changes.** If patches are in progress or code will be replaced, note this clearly so reviewers do not spend time on throwaway code.

## Document the codebase

- [ ] **Describe what your product does, who uses it, and how.** Use plain language to explain how contracts interact, the intended user flows, and design rationale.
- [ ] **Add inline comments on all public and external functions.** For Solidity, use [NatSpec](https://docs.soliditylang.org/en/latest/natspec-format.html) format (`@notice`, `@param`, `@return`, `@dev`).
- [ ] **Label and describe your tests.** Each test should state the exact behavior under test and the expected outcome, including negative cases.
- [ ] **Include past security reviews and known bug reports.** Prior findings give reviewers context on what has already been examined and what risk areas persist.

## Deliver the code batteries-included

- [ ] **Document the build environment.** Provide steps to set up a working environment from scratch, including all software versions, system dependencies, and external services.
- [ ] **Document the build and test process.** Include how to compile, run tests, and create the test environment. For Foundry projects, document any `forge script` or deployment steps.
- [ ] **Document the deployment process.** Specify deployment targets, constructor arguments, proxy configurations, and any post-deployment setup (e.g., role grants, parameter initialization).
- [ ] **Pin all dependency versions.** Use exact versions in `package.json`, `foundry.toml`, or equivalent. Ensure `forge install` or `npm ci` produces a reproducible build.

## Blockchain-specific preparation

- [ ] **Ensure Slither runs successfully on the target commit.** Document any intermediate setup if the project requires custom compilation steps. See [how to run Slither on a project](../program-analysis/slither).
- [ ] **Provide the exact commit hash, branch, or release tag for the review.** Confirm this before the engagement start date so reviewers work on a frozen snapshot.
- [ ] **Grant all assigned reviewers access to relevant repositories.** Verify access before the engagement commencement date, including any private dependencies or submodules.
- [ ] **Document privileged roles and access controls.** List all owner, admin, and operator roles, what permissions they hold, and which addresses hold those roles in production.
- [ ] **List all external dependencies and trust assumptions.** Identify oracles, bridges, AMMs, and other protocols the system depends on. Document what happens if an external dependency fails or is compromised.
- [ ] **Provide deployment addresses for any already-deployed components.** If the review covers an upgrade or new module integrated with existing contracts, include mainnet and testnet addresses.
