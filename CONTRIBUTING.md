# Contributing to Building-secure-contracts
First, thanks for your interest in contributing to Building-secure-contracts! We welcome and appreciate all contributions, including bug reports, feature suggestions, tutorials/blog posts, and code improvements.

If you're unsure where to start, we recommend our [`good first issue`](https://github.com/crytic/building-secure-contracts/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22) and [`help wanted`](https://github.com/crytic/building-secure-contracts/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22) issue labels.

## Bug reports and feature suggestions
Bug reports and feature suggestions can be submitted to our issue tracker. For bug reports, attaching the contract that caused the bug will help us in debugging and resolving the issue quickly. If you find a security vulnerability, do not open an issue; email opensource@trailofbits.com instead.

## Questions
Questions can be submitted to the issue tracker, but you may get a faster response if you ask in our [chat room](https://empireslacking.herokuapp.com/) (in the #ethereum channel).

## Code
building-secure-contracts uses the pull request contribution model. Please make an account on Github, fork this repo, and submit code contributions via pull request. For more documentation, look [here](https://guides.github.com/activities/forking/).

Some pull request guidelines:

- Minimize irrelevant changes (formatting, whitespace, etc) to code that would otherwise not be touched by this patch. Save formatting or style corrections for a separate pull request that does not make any semantic changes.
- When possible, large changes should be split up into smaller focused pull requests.
- Fill out the pull request description with a summary of what your patch does, key changes that have been made, and any further points of discussion, if applicable.
- Title your pull request with a brief description of what it's changing. "Fixes #123" is a good comment to add to the description, but makes for an unclear title on its own.

## Directory Structure

Below is a rough outline of building-secure-contracts's structure:
```text
.
├── development-guidelnes # High-level best-practices for all smart contracts
├── learn_evm # EVM technical knowledge
├── not-so-smart-contracts # Examples of smart contract common issues. Each issue contains a description, an example and recommendations
├── program-analysis # How to use automated tools to secure contracts
├── ressources # Various online resources
└── ...
```

## Linters

We run [markdown-link-check](https://github.com/tcort/markdown-link-check) to ensure all the markdown links are correct. 

To install `markdown-link-check`:
```bash
$ npm install -g markdown-link-check
```

To run `markdown-link-check`:

```bash
$ find . -name \*.md -print0 | xargs -0 -n1 markdown-link-check
```

## Create the book

We use `mdbook` to generate [secure-contracts.com](https://secure-contracts.com/).

To run it locally:
```
$ cargo install --git https://github.com/montyly/mdBook.git mdbook
$ mdbook build
```


Note: we use https://github.com/montyly/mdBook.git, which contains https://github.com/rust-lang/mdBook/pull/1584.
