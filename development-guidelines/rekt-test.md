# The Rekt Test

The Rekt Test is a 12-question security assessment framework created by Trail of Bits and blockchain security experts to help organizations evaluate their security posture. Inspired by [Joel Spolsky's Joel Test](https://www.joelonsoftware.com/2000/08/09/the-joel-test-12-steps-to-better-code/), it provides a quick way to assess security maturity.

The more questions your organization can answer "yes" to, the more you can trust the quality of your security operations.

## The 12 Questions

### Documentation and Planning

- [ ] **1. Do you have all actors, roles, and privileges documented?**

  Document who can do what in your system. This includes admin roles, privileged operations, and the scope of each role's permissions.

- [ ] **2. Do you keep documentation of all external services, contracts, and oracles you rely on?**

  Maintain an up-to-date list of all external dependencies, including third-party contracts, oracles, bridges, and off-chain services your system interacts with.

- [ ] **3. Do you have a written and tested incident response plan?**

  Have a documented plan for responding to security incidents. Test it regularly through tabletop exercises. See our [Incident Response Recommendations](./incident_response.md).

- [ ] **4. Do you document the best ways to attack your system?**

  Maintain a threat model that identifies potential attack vectors. Update it as your system evolves.

### Personnel and Access Control

- [ ] **5. Do you perform identity verification and background checks on all employees?**

  Verify the identity of team members, especially those with access to privileged systems or keys.

- [ ] **6. Do you have a team member with security defined in their role?**

  Assign explicit security responsibilities to at least one team member. Security should not be an afterthought.

- [ ] **7. Do you require hardware security keys for production systems?**

  Use hardware security keys (like YubiKeys) for accessing production systems and critical infrastructure.

- [ ] **8. Does your key management system require multiple humans and physical steps?**

  Implement multi-signature schemes and physical security measures for critical operations. No single person should be able to compromise the system.

### Technical Security

- [ ] **9. Do you define key invariants for your system and test them on every commit?**

  Identify the properties that must always hold true in your system and verify them automatically. Use tools like [Echidna](../program-analysis/echidna/README.md) or [Medusa](../program-analysis/medusa/docs/src/README.md) to test invariants continuously.

- [ ] **10. Do you use the best automated tools to discover security issues in your code?**

  Integrate security tools into your development workflow:

  - [Slither](../program-analysis/slither/docs/src/README.md) for static analysis
  - [Echidna](../program-analysis/echidna/README.md) or [Medusa](../program-analysis/medusa/docs/src/README.md) for fuzzing
  - See our [Secure Development Workflow](./workflow.md) for a complete checklist

- [ ] **11. Do you undergo external audits and maintain a vulnerability disclosure or bug bounty program?**

  Get independent security reviews before major releases. Maintain a way for security researchers to responsibly report vulnerabilities.

- [ ] **12. Have you considered and mitigated avenues for abusing users of your system?**

  Think beyond technical exploits. Consider how your system could be used to harm users through phishing, social engineering, or economic attacks.

## How to Use This Test

1. **Initial Assessment**: Go through each question honestly. A "yes" requires evidence, not just intention.

2. **Identify Gaps**: Questions you cannot answer "yes" to represent areas for improvement.

3. **Prioritize**: Not all questions are equally critical for every project. Prioritize based on your risk profile.

4. **Revisit Regularly**: Security posture changes over time. Reassess periodically, especially after major changes.

## Resources

- [Can you pass the Rekt Test?](https://blog.trailofbits.com/2023/08/14/can-you-pass-the-rekt-test/) - Original Trail of Bits blog post
- [Incident Response Recommendations](./incident_response.md) - Guidelines for question 3
- [Secure Development Workflow](./workflow.md) - Detailed workflow for questions 9-10
- [Program Analysis Tools](../program-analysis/README.md) - Tools for questions 9-10
