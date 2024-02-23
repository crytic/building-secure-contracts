# Token Integration Checklist

This checklist offers recommendations for interacting with arbitrary tokens. Ensure that every unchecked item is justified and that its risks are understood.

For convenience, all Slither [utilities](https://github.com/crytic/slither#tools) can be run directly on a token address, as shown below:

```bash
slither-check-erc 0xdac17f958d2ee523a2206206994597c13d831ec7 TetherToken --erc erc20
slither-check-erc 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d KittyCore --erc erc721
```

Use the following Slither output for the token to follow this checklist:

```bash
- slither-check-erc [target] [contractName] [optional: --erc ERC_NUMBER]
- slither [target] --print human-summary
- slither [target] --print contract-summary
- slither-prop . --contract ContractName # requires configuration, and use of Echidna and Manticore
```

## General Considerations

- [ ] **The contract has a security review.** Avoid interacting with contracts that lack a security review. Assess the review's duration (i.e., the level of effort), the reputation of the security firm, and the number and severity of findings.
- [ ] **You have contacted the developers.** If necessary, alert their team to incidents. Locate appropriate contacts on [blockchain-security-contacts](https://github.com/crytic/blockchain-security-contacts).
- [ ] **They have a security mailing list for critical announcements.** Their team should advise users (like you!) on critical issues or when upgrades occur.

## Contract Composition

- [ ] **The contract avoids unnecessary complexity.** The token should be a simple contract; tokens with complex code require a higher standard of review. Use Slither’s [`human-summary` printer](https://github.com/crytic/slither/wiki/Printer-documentation#human-summary) to identify complex code.
- [ ] **The contract uses `SafeMath`.** Contracts that do not use `SafeMath` require a higher standard of review. Inspect the contract manually for `SafeMath` usage.
- [ ] **The contract has only a few non-token-related functions.** Non-token-related functions increase the likelihood of issues in the contract. Use Slither’s [`contract-summary` printer](https://github.com/crytic/slither/wiki/Printer-documentation#contract-summary) to broadly review the code used in the contract.
- [ ] **The token has only one address.** Tokens with multiple entry points for balance updates can break internal bookkeeping based on the address (e.g., `balances[token_address][msg.sender]` might not reflect the actual balance).

## Owner Privileges

- [ ] **The token is not upgradeable.** Upgradeable contracts may change their rules over time. Use Slither’s [`human-summary` printer](https://github.com/crytic/slither/wiki/Printer-documentation#contract-summary) to determine if the contract is upgradeable.
- [ ] **The owner has limited minting capabilities.** Malicious or compromised owners can abuse minting capabilities. Use Slither’s [`human-summary` printer](https://github.com/crytic/slither/wiki/Printer-documentation#contract-summary) to review minting capabilities and consider manually reviewing the code.
- [ ] **The token is not pausable.** Malicious or compromised owners can trap contracts relying on pausable tokens. Identify pausable code manually.
- [ ] **The owner cannot blacklist the contract.** Malicious or compromised owners can trap contracts relying on tokens with a blacklist. Identify blacklisting features manually.
- [ ] **The team behind the token is known and can be held responsible for abuse.** Contracts with anonymous development teams or teams situated in legal shelters require a higher standard of review.

## ERC20 Tokens

### ERC20 Conformity Checks

Slither includes the [`slither-check-erc`](https://github.com/crytic/slither/wiki/ERC-Conformance) utility that checks a token's conformance to various ERC standards. Use `slither-check-erc` to review the following:

- [ ] **`Transfer` and `transferFrom` return a boolean.** Some tokens do not return a boolean for these functions, which may cause their calls in the contract to fail.
- [ ] **The `name`, `decimals`, and `symbol` functions are present if used.** These functions are optional in the ERC20 standard and may not be present.
- [ ] **`Decimals` returns a `uint8`.** Some tokens incorrectly return a `uint256`. In these cases, ensure the returned value is below 255.
- [ ] **The token mitigates the known [ERC20 race condition](https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729).** The ERC20 standard has a known race condition that must be mitigated to prevent attackers from stealing tokens.

Slither includes the [`slither-prop`](https://github.com/crytic/slither/wiki/Property-generation) utility, which generates unit tests and security properties to find many common ERC flaws. Use slither-prop to review the following:

- [ ] **The contract passes all unit tests and security properties from `slither-prop`.** Run the generated unit tests, then check the properties with [Echidna](https://github.com/crytic/echidna) and [Manticore](https://manticore.readthedocs.io/en/latest/verifier.html).

### Risks of ERC20 Extensions

The behavior of certain contracts may differ from the original ERC specification. Review the following conditions manually:

- [ ] **The token is not an ERC777 token and has no external function call in `transfer` or `transferFrom`.** External calls in the transfer functions can lead to reentrancies.
- [ ] **`Transfer` and `transferFrom` should not take a fee.** Deflationary tokens can lead to unexpected behavior.
- [ ] **Consider any interest earned from the token.** Some tokens distribute interest to token holders. If not taken into account, this interest may become trapped in the contract.

### Token Scarcity

Token scarcity issues must be reviewed manually. Check for the following conditions:

- [ ] **The supply is owned by more than a few users.** If a few users own most of the tokens, they can influence operations based on the tokens' distribution.
- [ ] **The total supply is sufficient.** Tokens with a low total supply can be easily manipulated.
- [ ] **The tokens are located in more than a few exchanges.** If all tokens are in one exchange, compromising the exchange could compromise the contract relying on the token.
- [ ] **Users understand the risks associated with large funds or flash loans.** Contracts relying on the token balance must account for attackers with large funds or attacks executed through flash loans.
- [ ] **The token does not allow flash minting.** Flash minting can lead to drastic changes in balance and total supply, requiring strict and comprehensive overflow checks in the token operation.

### Known non-standard ERC20 tokens

Protocols that allow integration with arbitrary tokens must take care to properly handle certain well-known non-standard ERC20 tokens. Refer to the [non-standard-tokens list](./non-standard-tokens.md) for a list of well-known tokens that contain additional risks.

## ERC721 Tokens

### ERC721 Conformity Checks

The behavior of certain contracts may differ from the original ERC specification. Review the following conditions manually:

- [ ] **Transfers of tokens to the 0x0 address revert.** Some tokens allow transfers to 0x0 and consider tokens sent to that address to have been burned; however, the ERC721 standard requires that such transfers revert.
- [ ] **`safeTransferFrom` functions are implemented with the correct signature.** Some token contracts do not implement these functions. Transferring NFTs to one of those contracts can result in a loss of assets.
- [ ] **The `name`, `decimals`, and `symbol` functions are present if used.** These functions are optional in the ERC721 standard and may not be present.
- [ ] **If used, `decimals` returns a `uint8(0)`.** Other values are invalid.
- [ ] **The `name` and `symbol` functions can return an empty string.** This behavior is allowed by the standard.
- [ ] **The `ownerOf` function reverts if the `tokenId` is invalid or refers to a token that has already been burned.** The function cannot return 0x0. This behavior is required by the standard but may not always be implemented correctly.
- [ ] **A transfer of an NFT clears its approvals.** This is required by the standard.
- [ ] **The token ID of an NFT cannot be changed during its lifetime.** This is required by the standard.

### Common Risks of the ERC721 Standard

Mitigate the risks associated with ERC721 contracts by conducting a manual review of the following conditions:

- [ ] **The `onERC721Received` callback is taken into account.** External calls in the transfer functions can lead to reentrancies, especially when the callback is not explicit (e.g., in [`safeMint`](https://www.paradigm.xyz/2021/08/the-dangers-of-surprising-code/) calls).
- [ ] **When an NFT is minted, it is safely transferred to a smart contract.** If a minting function exists, it should behave similarly to `safeTransferFrom` and handle the minting of new tokens to a smart contract properly, preventing asset loss.
- [ ] **Burning a token clears its approvals.** If a burning function exists, it should clear the token’s previous approvals.
