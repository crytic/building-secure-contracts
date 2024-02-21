# Incident Response Recommendations

How you respond during an incident is a direct reflection of your efforts to prepare for such an event. Each team or project's needs will vary so we provide the guidelines below as a starting point. Adherance to our guidelines can help you shift from a reactive approach to a **proactive** approach by planning with the assumption that incidents are inevitable. To fully leverage the following guidelines, consider them throughout the application development process.

## Application Design

- **Identify which components should or should not be:**
  - **Pausable**. While pausing a component can be beneficial during an incident, you must assess its potential impact on other contracts.
  - **Migratable or upgradeable**. Discovering a bug might necessitate a [migration strategy](https://blog.trailofbits.com/2018/10/29/how-contract-migration-works/) or contract upgrade to fix the issue; note, however, that upgradeability has its own [sets of risks](https://blog.trailofbits.com/2020/12/16/breaking-aave-upgradeability/). Making all contracts upgradeable might not be the best approach.
  - **Decentralized**. Using decentralized components can sometimes limit what rescue measures are possible and may require a higher amount of coordination.
- **Begin to identify important system invariants**. This helps to determine what you will need to monitor and what events may be necessary to do so effectively.
- **Evaluate what additional events are needed**. A missed event in a critical location might result in unnoticed incidents.
- **Evaluate what components must be on-chain and off-chain**. On-chain components are generally more at risk, but off-chain components push the risks to the off-chain owner.
- **Use fine-grained access controls**. Avoid setting all access controls to be available to an EOA. Opt for multisig wallets/MPC, and avoid delegating several roles to one address (e.g., the key responsible for setting fees shouldn't have access to the upgradeability feature).

## Documentation

- **Assemble a runbook of common actions you may need to perform**. It's not possible or practical to exhaustively detail how you'll respond to every type of incident. But you _can_ start to document procedures for some of the more important ones as well as actions that might be common across multiple scenarios (e.g., pausing, rotating owner keys, upgrading an implementation). This can also include scripts or snippets of code to facilitate performing these actions in a reproducible manner.
- **Document how to interpret events emission**. Only emitting events isn't sufficient; proper documentation is crucial, and users should be empowered to identify and decode them.
- **Document how to access wallets**. Clearly outline how to access wallets with special roles in the system. This should include both the location as well as access procedures for each wallet.
- **Document the deployment and upgrade process**. Deployment and upgrade processes are risky and must be thoroughly documented. This should include how to test the deployment/upgrade (e.g., using fork testing) and how to validate it (e.g., using a post-deployment script).
- **Document how to contact users and external dependencies**. Define guidelines regarding which stakeholders to contact, including the timing and mode of communication in case of incidents. The right communication at the right time is key to maintaining trust.

## Process

- **Conduct periodic training and incident response exercises**. Regularly organize training sessions and incident response exercises. Such measures ensure that employees remain updated and can help highlight any flaws in the current incident response protocol.
- **Remember to consider off-chain components when planning**. While much of this document is concerned with on-chain code, compromised frontends or social media accounts are also common sources of incidents.
- **Identify incident owners, with at least**:
  - **A technical lead**. Responsible for gathering and centralizing technical data.
  - **A communication lead**. Tasked with internal and external communication.
  - **A legal lead**. Either provides legal advice or ensures the right legal entities are contacted. It might also be worth considering liaison with appropriate law enforcement agencies.
- **Use monitoring tools**. You may opt for a third-party product, an in-house solution, or a combination of both. Third-party montoring will identify more generally suspicious transactions but may not be as in tune with system-specific metrics like health factors, collateralization ratios, or if an AMM invariant starts to drift. In-house monitoring, on the other hand, requires more engineering effort to setup and maintain, but can be tailored specifically to your needs.
- **Carefully consider automating certain actions based on monitoring alerts**. You may wish to automatically pause or move the system into a safer state if certain actvities are detected given how quickly some exploits are carried out. However, also keep in mind the impact and likelihood of a false positive triggering such a mechanism and how disruptive that could be.

## Threat Intelligence

- **Identify similar protocols, and stay informed of any issues affecting them**. This could include forks, implementations on other chains, or protocols in the same general class (e.g., other lending protocols). Being aware of vulnerabilities in similar systems can help preemptively address potential threats in your own.
- **Identify your dependencies, and follow their communication channels to be alerted in case of an issue.** Follow their Twitter, Discord, Telegram, newsletter, etc. This includes both on-chain as well as off-chain (e.g., libraries, toolchain) dependencies.
- **Maintain open communication lines with your dependencies' owners**. This will help you to stay informed if one of your dependencies is compromised.
- **Subscribe to the [BlockThreat](https://newsletter.blockthreat.io/) newsletter**. BlockThreat will keep you informed about recent incidents and developments in blockchain security. The nature of blockchains means we have a culture of learning in the open so take advantage of this and learn from your peers.

Additionally, consider conducting a threat modeling exercise. This exercise will identify risks that an application faces at both the structural and operational level. If you're interested in undertaking such an exercise and would like to work with us, [contact us](https://www.trailofbits.com/contact/).

## Resources

- [An Incident Response Plan for Startups](https://medium.com/starting-up-security/an-incident-response-plan-for-startups-26549596b914)
  - A minimum viable incident response plan, a great starting point for a smaller team. Especially in combination with the Yearn example below, which is tailored a bit more for web3 teams.
- [The practical guide to incident management](https://incident.io/guide)
  - An approachable guide for incident response. Chapter 4 includes examples for how to approach practicing your process.
- [PagerDuty Incident Response](https://response.pagerduty.com/)
  - A _very_ detailed handbook of how PagerDuty handles incident response themselves. Some useful ideas and resources, but more practical for larger organizations.
- [How to Hack the Yield Protocol](https://docs.yieldprotocol.com/#/operations/how_to_hack)
- [Emergency Procedures for Yearn Finance](https://github.com/yearn/yearn-devdocs/blob/master/docs/developers/v2/EMERGENCY.md)
- [Rekt pilled: What to do when your dApp gets pwned and how to stay kalm - Heidi Wilder (DSS 2023)](https://www.youtube.com/watch?v=TDlkkg8N0wc)
- [Crisis Handbook - Smart Contract Hack (SEAL)](https://docs.google.com/document/d/1DaAiuGFkMEMMiIuvqhePL5aDFGHJ9Ya6D04rdaldqC0/edit)

### Community Incident Retrospectives

- [Yield Protocol](https://medium.com/yield-protocol/post-mortem-of-incident-on-august-5th-2022-7bb70dbb9ada)
