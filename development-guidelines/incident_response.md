# Incident Response Guidelines

How you respond during an incident is a direct reflection of your efforts to prepare for such an event. Adherance to our guidelines can help you shift from a reactive approach to a **proactive** approach by planning with the assumption that incidents are inevitable. To fully leverage the following guidelines, consider them throughout the application development process.

## Application design

- **Identify the components that should/should not be**
  - **Pausable**. While pausing a component can be beneficial during an incident, you must assess its potential impact on other contracts.
  - **Migratable or upgradeable**. Discovering a bug might necessitate a [migration strategy](https://blog.trailofbits.com/2018/10/29/how-contract-migration-works/) or contract upgrade to fix the issue; note, however, that upgradeability has its own [sets of risks](https://blog.trailofbits.com/2020/12/16/breaking-aave-upgradeability/). Making all contracts upgradeable might not be the best approach.
  - **Decentralized**. Using decentralized components can sometimes restrict rescue measures.
- **Evaluate what events are needed**. A missed event in a critical location might result in unnoticed incidents.
- **Evaluate what components must be on-chain and off-chain**. On-chain components are generally more at risk, but off-chain components push the risks to the off-chain owner.
- **Use an access control that allows fine-grained access**. Avoid setting all access controls to be available to an EOA. Opt for multisig wallets/MPC, and segregate access (e.g., the key responsible for setting fees shouldn't have access to the upgradeability feature).

## Documentation

- **Document how to interpret abnormal events emission**. Only emitting events isn't sufficient; proper documentation is crucial, and users should be empowered to decode them.
- **Document how to access wallets**. Clearly outline how to access wallets. Both the location and access procedures for every wallet should be clear and straightforward.
- **Document the deployment and upgrade process**. Deployment and upgrade processes are risky and must be thoroughly documented. This should include how to test the deployment/upgrade (ex: using fork testing) and how to validate it (ex: using a post-deployment script).
- **Document how to contact the users and external dependencies**. Define guidelines regarding which stakeholders to contact, including the timing and mode of communication in case of incidents.

## Process

- **Conduct periodic training and incident response exercises**. Regularly organize training sessions and incident response exercises. Such measures ensure that employees remain updated and can help highlight any flaws in the current incident response protocol.
- **Identify incident owners, with at least**:
  - **A technical lead**. Responsible for gathering and centralizing technical data.
  - **A communication lead**. Tasked with internal and external communication.
  - **A legal lead**. Either provides legal advice or ensures the right legal entities are contacted. It might also be worth considering liaison with appropriate law enforcement agencies.
- **Use automated monitoring tools**. Whether you opt for an in-house solution or third-party products, automation is key. While considering automated responses like pausing the system in the event of irregular activities, exercise caution. Without careful configuration, automatic responses might inadvertently facilitate denial-of-service (DOS) exploits.

## Threat Intelligence

- **Identify similar protocols, and stay informed of related compromises**. Being aware of vulnerabilities in similar systems can help preemptively address potential threats in your own.
- **Identify dependencies, and monitor their behaviors to be alerted in case of compromise.** Follow twitter, discord, newsletter, etc.
- **Maintain open communication lines with your dependencies owners**. This will help you to stay informed if one of your dependency is compromised.
- **Subscribe to https://newsletter.blockthreat.io/**. BlockThreat will help you stay informed about recent incidents.

Additionally, consider conducting a threat modeling exercise. This exercise will identify risks that an application faces at both the structural and operational level. If you're interested in undertaking such an exercise and would like to work with us, [contact us](https://www.trailofbits.com/contact/).

## Incident Response Plan Resources

- [How to Hack the Yield Protocol](https://docs.yieldprotocol.com/#/operations/how_to_hack)
- [Emergency Steps – Yearn](https://github.com/yearn/yearn-devdocs/blob/master/docs/developers/v2/EMERGENCY.md)
- [Monitoring & Incident Response - Heidi Wilder (DSS 2023)](https://www.youtube.com/watch?v=TDlkkg8N0wc)

### Examples of incidents retrospective

- [Yield Protocol](https://medium.com/yield-protocol/post-mortem-of-incident-on-august-5th-2022-7bb70dbb9ada)
