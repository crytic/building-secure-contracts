# Incident Response Recommendations

In this article, we provide recommendations for formulating a robust incident response plan.

- [ ] **Identify specific individuals or roles responsible for carrying out the mitigations (deploying smart contracts, pausing contracts, upgrading the front end, etc.).**
  - Defining these roles will enhance the incident response plan and facilitate the execution of mitigation actions when necessary.
- [ ] **Document internal processes in cases where deployed remediation fails or introduces new bugs.**
  - Consider developing a fallback plan that outlines an action strategy for failed remediation attempts.
- [ ] **Provide a clear description of the intended contract deployment process.**
- [ ] **Contemplate whether and under what circumstances your company will compensate affected users in the event of certain issues.**
  - Some situations to consider include individual or aggregate losses, losses resulting from user error, contract flaws, and third-party contract defects.
- [ ] **Outline a plan for staying informed about new issues, so as to ensure future development and the security of the deployment toolchain and the external on-chain and off-chain services your system depends on.**
  - For each language and component, identify reputable sources of vulnerability news. Subscribe to updates for each source. Consider creating a private Discord or Slack channel with a bot that posts the latest vulnerability news to help your team stay informed in a centralized location. Additionally, consider assigning specific team members to track vulnerability news for particular system components.
- [ ] **Examine scenarios involving issues that would indirectly affect the system.**
- [ ] **Decide when and how the team should seek assistance from or collaborate with external parties (auditors, affected users, other protocol developers, etc.).**
  - Some problems may necessitate cooperation with external parties for efficient resolution.
- [ ] **Define abnormal contract behavior for off-chain monitoring purposes.**
  - Consider implementing more robust detection and mitigation solutions, including specific alternate endpoints, queries for diverse data, status pages, and support contacts for impacted services.
- [ ] **Combine issues to evaluate whether new detection and mitigation scenarios are necessary.**
- [ ] **Conduct periodic dry runs of specific scenarios in the incident response plan to identify gaps and improvement opportunities, and build muscle memory.**
  - Establish intervals for performing dry runs for each scenario. Conduct more frequent dry runs for scenarios with higher likelihoods of occurrence. Create a template to document improvements required after each dry run for the incident response plan.

## Incident Response Plan Resources

- [How to Hack the Yield Protocol](https://docs.yieldprotocol.com/#/operations/how_to_hack)
- [Emergency Steps – Yearn](https://github.com/yearn/yearn-devdocs/blob/master/docs/developers/v2/EMERGENCY.md)

## Examples of Well-Handled Incident Response Incidents

- [Yield Protocol](https://medium.com/yield-protocol/post-mortem-of-incident-on-august-5th-2022-7bb70dbb9ada)
