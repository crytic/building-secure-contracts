# Contributing to Building-Secure-Contracts

First, thank you for your interest in contributing to Building-Secure-Contracts! We appreciate and warmly welcome all contributions, which include bug reports, feature suggestions, tutorials/blog posts, and code improvements.

If you're not sure where to begin, we recommend checking out our [`good first issue`](https://github.com/crytic/building-secure-contracts/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22) and [`help wanted`](https://github.com/crytic/building-secure-contracts/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22) issue labels.

## Bug Reports and Feature Suggestions

Please submit bug reports and feature suggestions to our issue tracker. When reporting a bug, attaching the contract causing the issue is helpful for efficient debugging and resolution. If you discover a security vulnerability, do not open an issue; instead, email opensource@trailofbits.com.

## Questions

Questions can be submitted to the issue tracker, but you may get a faster response if you ask in our [chat room](https://slack.empirehacking.nyc/) (in the #ethereum channel).

## Code Contributions

Building-Secure-Contracts follows the pull request contribution model. Create an account on Github, fork this repo, and submit code contributions through pull requests. For additional documentation, refer [here](https://guides.github.com/activities/forking/).

Some pull request guidelines:

- Limit unnecessary changes (formatting, whitespace, etc.) to code unrelated to the patch. Save formatting or style corrections for a separate pull request, which doesn't include any semantic changes.
- When possible, break down large changes into smaller, focused pull requests.
- Complete the pull request description with an overview of your patch, including key modifications, and any further discussion points if relevant.
- Use a concise title to describe your pull request's changes. "Fixes #123" is suitable for adding to the description, but not as a standalone title.

## Directory Structure

Here's a basic overview of Building-Secure-Contracts' structure:

```text
.
├── development-guidelines # High-level best practices for all smart contracts
├── learn_evm # EVM technical knowledge
├── not-so-smart-contracts # Examples of common smart contract issues, including descriptions, examples, and recommendations
├── program-analysis # How to utilize automated tools to secure contracts
├── resources # Various online resources
└── ...
```

## Linting and Formatting

To install the formatters and linters, run:

```bash
npm install
```

To use the formatter, run:

```bash
npm run format
```

To use the linters, run:

```bash
npm run lint
```

To use individual linters, run:

- `npm run lint:format` to check the formatting
- `npm run lint:links` to verify the validity of links in markdown files

## Creating the Book

We utilize `mdbook` to generate [secure-contracts.com](https://secure-contracts.com/).

To run it locally:

```
cargo install --git https://github.com/montyly/mdBook.git mdbook
mdbook build
```

Note: We use https://github.com/montyly/mdBook.git, which contains https://github.com/rust-lang/mdBook/pull/1584.
