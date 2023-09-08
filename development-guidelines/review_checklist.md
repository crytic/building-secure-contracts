# Preparing for a Security Review Checklist

Here’s how to make that security review more effective, valuable, and satisfying for everybody involved.

### Resolve the Easy Issues

- [] **Enable and address compiler warnings.** Go after the easy stuff first: turn on every single compiler warning you can find, understand each warning, then fix your code until they’re all gone. Upgrade your compiler to the latest version, then fix all the new warnings and errors. Even innocuous seeming warnings can indicate problems lying in wait.
- [] **Increase unit and feature test coverage.** Ideally this has been part of the development process, but everyone slips up, tests don’t get updated, or new features don’t quite match the old integrations tests. Now is the time to update the tests and run them all.
- [] **Remove dead code, stale branches, unused libraries, and other extraneous weight.** You may know which branch is active and which is dead but the consultants won’t and will waste time investigating it for potential issues. The same goes for that new feature that hasn’t seen progress in months, or that third-party library that doesn’t get used anymore.

### Document

- [] **Provide external documentation and reports from any prior security reviews.**
- [] **Describe what your product does, who uses it, and how.** The most important documentation is high level: what does your product do? What do users want from it? How does it achieve that goal? Use clear language to describe how systems interact and the rationale for design decisions made during development.
- [] **Add comments in-line with the code. Preferably in NatSpec format.** Functions should have comments containing high-level descriptions of their intended behavior. Complicated sections of code should have comments describing what is happening and why this particular approach was chosen.
- [] **Label and describe your tests.** More complicated tests should describe the exact behavior they’re testing. The expected results of tests, both positive and negative, should be documented.

### Deliver the Code, Batteries Included

- [] **Prepare the build environment.** Document the steps to create a build environment from scratch on a computer that is fully disconnected from your internal network. Where relevant, be specific about software versions. Walk through this process on your own to ensure that it is complete. If you have external dependencies that are not publicly available, include them with your code. Fully provisioned virtual machine images are a great way to deliver a working build environment.
- [] **Document the build process.** Include both the debug and release build processes, and also include steps on how to build and run the tests. If the test environment is distinct from the build environment, include steps on how to create the test environment. A well-documented build process enables a consultant to run static analysis tools far more efficiently and effectively.
- [] **Document the deploy process.** This includes how to build the deployment environment. It is very important to list all the specific versions of external tools and libraries for this process, as the deployment environment is a considerable factor in evaluating the security of your product. A well-documented deployment process enables a consultant to run dynamic analysis tools in a real world environment.
