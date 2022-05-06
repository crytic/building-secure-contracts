# Incident Response Recommendations 

Here, we provide recommendations around the formulation of an incident response plan. 

- [ ] **Identify who (either specific people or roles) is responsible for carrying out the mitigations (deploying smart contracts, pausing contracts, upgrading the front end, etc.).**
  - Specifying these roles will strengthen the incident response plan and ease the execution of mitigating actions when necessary.
- [ ] **Document internal processes for situations in which a deployed remediation does not work or introduces a new bug.**
  - Consider adding a fallback scenario that describes an action plan in the event of a failed remediation.
- [ ] **Clearly describe the intended process of contract deployment.**
- [ ] **Consider whether and under what circumstances your company will make affected users whole after certain issues occur.**
  - Some scenarios to consider include an individual or aggregate loss, a loss resulting from user error, a contract flaw, and a third-party contract flaw.
- [ ] **Document how you plan to keep up to date on new issues, both to inform future development and to secure the deployment toolchain and the external on-chain and off-chain services that the system relies on.**
  - For each language and component, describe the noteworthy sources for vulnerability news. Subscribe to updates for each source. Consider creating a special private Discord/Slack channel with a bot that will post the latest vulnerability news; this will help the team keep track of updates all in one place. Also consider assigning specific team members to keep track of the vulnerability news of a specific component of the system.
- [ ] **Consider scenarios involving issues that would indirectly affect the system.**
- [ ] **Determine when and how the team would reach out to and onboard external parties (auditors, affected users, other protocol developers, etc.).**
  - Some issues may require collaboration with external parties to efficiently remediate them. 
- [ ] **Define contract behavior that is considered abnormal for off-chain monitoring.**
  - Consider adding more resilient solutions for detection and mitigation, especially in terms of specific alternate endpoints and queries for different data as well as status pages and support contacts for affected services.
- [ ] **Combine issues and determine whether new detection and mitigation scenarios are needed.**
- [ ] **Perform periodic dry runs of specific scenarios in the incident response plan to find gaps and opportunities for improvement and to develop muscle memory.**
  - Document the intervals at which the team should perform dry runs of the various scenarios. For scenarios that are more likely to happen, perform dry runs more regularly. Create a template to be filled in after a dry run to describe the improvements that need to be made to the incident response.  