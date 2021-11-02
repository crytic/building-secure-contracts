# Token integration checklist

Follow this checklist when interacting with arbitrary tokens. Make sure you understand the risks associated with each item, and justify any exceptions to these rules.

For convenience, all Slither [utilities](https://github.com/crytic/slither#tools) can be run directly on a token address, such as:

```bash
slither-check-erc 0xdac17f958d2ee523a2206206994597c13d831ec7 TetherToken --erc erc20
slither-check-erc 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d KittyCore --erc erc721
```

To follow this checklist, you'll want to have this output from Slither for the token:

```bash
- slither-check-erc [target] [contractName] [optional: --erc ERC_NUMBER]
- slither [target] --print human-summary
- slither [target] --print contract-summary
- slither-prop . --contract ContractName # requires configuration, and use of Echidna and Manticore
```

## General considerations

- [ ] **The contract has a security review.** Avoid interacting with contracts that lack a security review. Check the length of the assessment (aka “level of effort”), the reputation of the security firm, and the number and severity of the findings.
- [ ] **You have contacted the developers.** You may need to alert their team to an incident. Look for appropriate contacts on [blockchain-security-contacts](https://github.com/crytic/blockchain-security-contacts).
- [ ] **They have a security mailing list for critical announcements.** Their team should advise users (like you!) when critical issues are found or when upgrades occur.

## Contract composition

- [ ] **The contract avoids unneeded complexity.** The token should be a simple contract; a token with complex code requires a higher standard of review. Use Slither’s [human-summary printer](https://github.com/crytic/slither/wiki/Printer-documentation#human-summary) to identify complex code.
- [ ] **The contract uses SafeMath.** Contracts that do not use SafeMath require a higher standard of review. Inspect the contract by hand for SafeMath usage.
- [ ] **The contract has only a few non–token-related functions.** Non–token-related functions increase the likelihood of an issue in the contract. Use Slither’s [contract-summary printer](https://github.com/crytic/slither/wiki/Printer-documentation#contract-summary) to broadly review the code used in the contract.
- [ ] **The token only has one address.** Tokens with multiple entry points for balance updates can break internal bookkeeping based on the address (e.g. `balances[token_address][msg.sender]` might not reflect the actual balance).

## Owner privileges

- [ ] **The token is not upgradeable.** Upgradeable contracts might change their rules over time. Use Slither’s [human-summary printer](https://github.com/crytic/slither/wiki/Printer-documentation#contract-summary) to determine if the contract is upgradeable.
- [ ] **The owner has limited minting capabilities.** Malicious or compromised owners can abuse minting capabilities. Use Slither’s [human-summary printer](https://github.com/crytic/slither/wiki/Printer-documentation#contract-summary) to review minting capabilities, and consider manually reviewing the code.
- [ ] **The token is not pausable.** Malicious or compromised owners can trap contracts relying on pausable tokens. Identify pauseable code by hand.
- [ ] **The owner cannot blacklist the contract.** Malicious or compromised owners can trap contracts relying on tokens with a blacklist. Identify blacklisting features by hand.
- [ ] **The team behind the token is known and can be held responsible for abuse.** Contracts with anonymous development teams, or that reside in legal shelters should require a higher standard of review.

## ERC-20 tokens 

### Suggested ERC-20 conformity checks

Slither includes a utility, [slither-check-erc](https://github.com/crytic/slither/wiki/ERC-Conformance), that reviews the conformance of a token to many related ERC standards. Use slither-check-erc to review that:

- [ ] **Transfer and transferFrom return a boolean.** Several tokens do not return a boolean on these functions. As a result, their calls in the contract might fail. 
- [ ] **The name, decimals, and symbol functions are present if used.** These functions are optional in the ERC20 standard and might not be present.
- [ ] **Decimals returns a uint8.** Several tokens incorrectly return a uint256. If this is the case, ensure the value returned is below 255.
- [ ] **The token mitigates the known [ERC20 race condition](https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729).** The ERC20 standard has a known ERC20 race condition that must be mitigated to prevent attackers from stealing tokens.

Slither includes a utility, [slither-prop](https://github.com/crytic/slither/wiki/Property-generation), that generates unit tests and security properties that can discover many common ERC flaws. Use slither-prop to review that:

- [ ] **The contract passes all unit tests and security properties from slither-prop.** Run the generated unit tests, then check the properties with [Echidna](https://github.com/crytic/echidna) and [Manticore](https://manticore.readthedocs.io/en/latest/verifier.html).

### Risks in ERC-20 extensions
Contracts might have different behaviors from their original ERC specification, manually review that:

- [ ] **The token is not an ERC777 token and has no external function call in transfer and transferFrom.** External calls in the transfer functions can lead to reentrancies.
- [ ] **Transfer and transferFrom should not take a fee.** Deflationary tokens can lead to unexpected behavior.
- [ ] **Potential interest earned from the token is taken into account.** Some tokens distribute interest to token holders. This interest might be trapped in the contract if not taken into account.

### Token scarcity

Reviews for issues of token scarcity requires manual review. Check for these conditions:

- [ ] **No user owns most of the supply.** If a few users own most of the tokens, they can influence operations based on the token's repartition.
- [ ] **The total supply is sufficient.** Tokens with a low total supply can be easily manipulated.
- [ ] **The tokens are located in more than a few exchanges.** If all the tokens are in one exchange, a compromise of the exchange can compromise the contract relying on the token.
- [ ] **Users understand the associated risks of large funds or flash loans.** Contracts relying on the token balance must carefully take in consideration attackers with large funds or attacks through flash loans.
- [ ] **The token does not allow flash minting**. Flash minting can lead to substantial swings in the balance and the total supply, which neccessitate strict and comprehensive overflow checks in the operation of the token. 

## ERC-721 tokens 

### Suggested ERC-721 conformity checks
Contracts might have different behavior from their original ERC specification. Manually review that:

- [ ] **Transfering tokens to 0x0 reverts.** Several tokens allow transfering to 0x0, counting these as burned, however the ERC-721 standard requires a revert in such case.
- [ ] **safeTransferFrom functions are implemented with the correct signature.** Several tokens do not implement these functions. As a result, transferring NFTs into a contract can result in loss of assets.
- [ ] **The name, decimals, and symbol functions are present if used.** These functions are optional in the ERC721 standard and might not be present.
- [ ] **If used, decimals should return uint8(0).** Other values are not valid.
- [ ] **The name and symbol functions can return an empty string.** This is allowed by the standard.
- [ ] **ownerOf reverts if the `tokenId` is invalid or it was already burned. This function cannot return 0x0**. This is required by the standard, but it is not always properly implemented.
- [ ] **Transferring an NFT clears its approvals**. This is required by the standard.
- [ ] **The token id from an NFT cannot be changed during its lifetime**. This is required by the standard.

### Common risks to ERC-721

ERC-721 contracts are exposed to the following risks when implementing:

- [ ] **The onERC721Received callback is commonly exploited.** External calls in the transfer functions can lead to reentrancies. This is particulary risky when the callback is not explicit. E.g., when [calling `safeMint`](https://www.paradigm.xyz/2021/08/the-dangers-of-surprising-code/).
- [ ] **Minting safely transfers an NFT to a smart contract**. If there is a function to mint, it should properly handle minting new tokens to a smart contract (similarly to `safeTransferFrom`) to avoid loss of assets.
- [ ] **Burning clears approvals**. If there is a function to burn, it should clear previous approvals.

