# Secure Development Workflow

Follow this high-level process while developing your smart contracts for enhanced security:

1. **Check for known security issues:**

- [ ] Review your contracts using [Slither](https://github.com/crytic/slither), which has over 70 built-in detectors for common vulnerabilities. Run it on every check-in with new code and ensure it gets a clean report (or use triage mode to silence certain issues).

2. **Consider special features of your contract:**

- [ ] If your contracts are upgradeable, review your upgradeability code for flaws using [`slither-check-upgradeability`](https://github.com/crytic/slither/wiki/Upgradeability-Checks) or [Crytic](https://blog.trailofbits.com/2020/06/12/upgradeable-contracts-made-safer-with-crytic/). We have documented 17 ways upgrades can go sideways.
- [ ] If your contracts claim to conform to ERCs, check them with [`slither-check-erc`](https://github.com/crytic/slither/wiki/ERC-Conformance). This tool instantly identifies deviations from six common specs.
- [ ] If you have unit tests in Truffle, enrich them with [`slither-prop`](https://github.com/crytic/slither/wiki/Property-generation). It automatically generates a robust suite of security properties for features of ERC20 based on your specific code.
- [ ] If you integrate with third-party tokens, review our [token integration checklist](./token_integration.md) before relying on external contracts.

3. **Visually inspect critical security features of your code:**

- [ ] Review Slither's [inheritance-graph](https://github.com/trailofbits/slither/wiki/Printer-documentation#inheritance-graph) printer to avoid inadvertent shadowing and C3 linearization issues.
- [ ] Review Slither's [function-summary](https://github.com/trailofbits/slither/wiki/Printer-documentation#function-summary) printer, which reports function visibility and access controls.
- [ ] Review Slither's [vars-and-auth](https://github.com/trailofbits/slither/wiki/Printer-documentation#variables-written-and-authorization) printer, which reports access controls on state variables.

4. **Document critical security properties and use automated test generators to evaluate them:**

- [ ] Learn to [document security properties for your code](../program-analysis/). Although challenging at first, it is the single most important activity for achieving a good outcome. It is also a prerequisite for using any advanced techniques in this tutorial.
- [ ] Define security properties in Solidity for use with [Echidna](https://github.com/crytic/echidna) and [Manticore](https://manticore.readthedocs.io/en/latest/verifier.html). Focus on your state machine, access controls, arithmetic operations, external interactions, and standards conformance.
- [ ] Define security properties with [Slither's Python API](../program-analysis/slither). Concentrate on inheritance, variable dependencies, access controls, and other structural issues.

5. **Be mindful of issues that automated tools cannot easily find:**

- Lack of privacy: Transactions are visible to everyone else while queued in the pool.
- Front running transactions.
- Cryptographic operations.
- Risky interactions with external DeFi components.

## Ask for help

[Office Hours](https://meetings.hubspot.com/trailofbits/office-hours) are held every Tuesday afternoon. These one-hour, one-on-one sessions provide an opportunity to ask questions about security, troubleshoot tool usage, and receive expert feedback on your current approach. We will help you work through this guide.

Join our Slack: [Empire Hacking](https://join.slack.com/t/empirehacking/shared_invite/zt-h97bbrj8-1jwuiU33nnzg67JcvIciUw). We are always available in the #crytic and #ethereum channels if you have questions.

## Security is about more than just smart contracts

Review our quick tips for [general application and corporate security](https://docs.google.com/document/d/1-_0Wlwch_vtkPM4F-SdEXLjQYaYT7KoPlU2rjt7tkLQ/edit?usp=sharing). While it is crucial to ensure on-chain code security, off-chain security lapses can be equally severe, especially regarding owner keys.
