# Security Review Preparation Checklist

Get ready for your security review! Ensuring a few key elements are in place before the review starts can make the process significantly smoother for both sides.

💡 **ProTip 1:** Predefine areas of focus and provide the review team early access to your codebase.

- Provide a detailed list of files for review.
- Freeze a stable commit hash, branch, or release prior to review.
- Pinpoint areas in the codebase that previously had issues, inspire less confidence, or are of particular concern.
- If your codebase is a fork of an existing protocol, delinate the differences and modifications you made compared to the original codebase.

💡 **ProTip 2:** Lay the groundwork for your review by ensuring your project is build-ready. This allows us to focus on giving you actionable recommendations instead of trying to build your code!

- Create a clear set of build instructions.
- Confirm your setup process by cloning and testing your repository on a fresh environment.

💡 **ProTip 3:** Streamline our process of building a mental model of your codebase by providing comprehensive documentation.

- Create flowcharts and sequence diagrams to depict primary workflows.
- List actors and with their respective roles and privileges.
- Incorporate external developer documentation that links directly to your code.
- Add inline comments for complex areas of your system.
- Maintain comprehensive NatSpec descriptions for all functions.
- Create short video walkthroughs for complex workflows or areas of concern.

💡 **ProTip 4:** Share your test suite and coverage report with us to better understand the system.

- Provide your test coverage report.
- Share unit and stateful fuzz tests.
- Share fuzz and differential tests.

💡 **ProTip 5:** For arithmetic-heavy codebases, meticulously document and map all of your formulas.

- Document every formula implemented in your codebase.
- Map each formula to in-code implementation and if there are deviations between these two, include derivations.
- Share all rounding direction analysis.
- Share results from any economic analysis conducted on your codebase.

💡 **ProTip 6:** Expedite familiarisation of your codebase by detailing all assumptions.

- List system invariants.
- Identify the parameter ranges (minimum and maximum values) used in your system.
- Highlight unreachable or logically excluded system states.
- Compile a glossary for consistent terminology use.
- List external dependencies used and their purpose.

💡 **ProTip 7:** Clarify all interactions within the system. Highlight how contracts work together on-chain and how your contract interfaces with off-chain components.

- Create an architecture diagram of on-chain contract interactions.
- Document all design decisions, including engineering trade-offs, and discarded alternatives.
- If your system uses off-chain components, outline data validation procedures off-chain and the input bounds for on-chain functions.
- If your system has bridge-like functionality, document values passing between source and destination chains.
