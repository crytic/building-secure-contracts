# Token integration checklist

The following checklist provides recommendations for interactions with arbitrary tokens. Every unchecked item should be justified, and its associated risks, understood.

For convenience, all Slither [utilities](https://github.com/crytic/slither#tools) can be run directly on a token address, such as the following:

```bash
slither-check-erc 0xdac17f958d2ee523a2206206994597c13d831ec7 TetherToken --erc erc20
slither-check-erc 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d KittyCore --erc erc721
```

To follow this checklist, use the below output from Slither for the token:

```bash
- slither-check-erc [target] [contractName] [optional: --erc ERC_NUMBER]
- slither [target] --print human-summary
- slither [target] --print contract-summary
- slither-prop . --contract ContractName # requires configuration, and use of Echidna and Manticore
```

## General considerations

- [ ] **The contract has a security review.** Avoid interacting with contracts that lack a security review. Check the length of the assessment (i.e., the level of effort), the reputation of the security firm, and the number and severity of the findings.
- [ ] **You have contacted the developers.** You may need to alert their team to an incident. Look for appropriate contacts on [blockchain-security-contacts](https://github.com/crytic/blockchain-security-contacts).
- [ ] **They have a security mailing list for critical announcements.** Their team should advise users (like you!) when critical issues are found or when upgrades occur.

## Contract composition

- [ ] **The contract avoids unneeded complexity.** The token should be a simple contract; a token with complex code requires a higher standard of review. Use Slither’s [`human-summary` printer](https://github.com/crytic/slither/wiki/Printer-documentation#human-summary) to identify complex code.
- [ ] **The contract uses `SafeMath`.** Contracts that do not use `SafeMath` require a higher standard of review. Inspect the contract by hand for `SafeMath` usage.
- [ ] **The contract has only a few non–token-related functions.** Non-token-related functions increase the likelihood of an issue in the contract. Use Slither’s [`contract-summary` printer](https://github.com/crytic/slither/wiki/Printer-documentation#contract-summary) to broadly review the code used in the contract.
- [ ] **The token only has one address.** Tokens with multiple entry points for balance updates can break internal bookkeeping based on the address (e.g., `balances[token_address][msg.sender]` may not reflect the actual balance).

## Owner privileges

- [ ] **The token is not upgradeable.** Upgradeable contracts may change their rules over time. Use Slither’s [`human-summary` printer](https://github.com/crytic/slither/wiki/Printer-documentation#contract-summary) to determine whether the contract is upgradeable.
- [ ] **The owner has limited minting capabilities.** Malicious or compromised owners can abuse minting capabilities. Use Slither’s [`human-summary` printer](https://github.com/crytic/slither/wiki/Printer-documentation#contract-summary) to review minting capabilities, and consider manually reviewing the code.
- [ ] **The token is not pausable.** Malicious or compromised owners can trap contracts relying on pausable tokens. Identify pausable code by hand.
- [ ] **The owner cannot blacklist the contract.** Malicious or compromised owners can trap contracts relying on tokens with a blacklist. Identify blacklisting features by hand.
- [ ] **The team behind the token is known and can be held responsible for abuse.** Contracts with anonymous development teams or teams that reside in legal shelters require a higher standard of review.

## ERC20 tokens

### ERC20 conformity checks

Slither includes a utility, [`slither-check-erc`](https://github.com/crytic/slither/wiki/ERC-Conformance), that reviews the conformance of a token to many related ERC standards. Use `slither-check-erc` to review the following:

- [ ] **`Transfer` and `transferFrom` return a boolean.** Several tokens do not return a boolean on these functions. As a result, their calls in the contract might fail.
- [ ] **The `name`, `decimals`, and `symbol` functions are present if used.** These functions are optional in the ERC20 standard and may not be present.
- [ ] **`Decimals` returns a `uint8`.** Several tokens incorrectly return a `uint256`. In such cases, ensure that the value returned is below 255.
- [ ] **The token mitigates the known [ERC20 race condition](https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729).** The ERC20 standard has a known ERC20 race condition that must be mitigated to prevent attackers from stealing tokens.

Slither includes a utility, [`slither-prop`](https://github.com/crytic/slither/wiki/Property-generation), that generates unit tests and security properties that can discover many common ERC flaws. Use slither-prop to review the following:

- [ ] **The contract passes all unit tests and security properties from `slither-prop`.** Run the generated unit tests and then check the properties with [Echidna](https://github.com/crytic/echidna) and [Manticore](https://manticore.readthedocs.io/en/latest/verifier.html).

### Risks of ERC20 Extensions

The behavior of certain contracts may differ from the original ERC specification. Conduct a manual review of the following conditions:

- [ ] **The token is not an ERC777 token and has no external function call in `transfer` or `transferFrom`.** External calls in the transfer functions can lead to reentrancies.
- [ ] **`Transfer` and `transferFrom` should not take a fee.** Deflationary tokens can lead to unexpected behavior.
- [ ] **Potential interest earned from the token is taken into account.** Some tokens distribute interest to token holders. This interest may be trapped in the contract if not taken into account.

### Token scarcity

Reviews of token scarcity issues must be executed manually. Check for the following conditions:

- [ ] **The supply is owned by more than a few users.** If a few users own most of the tokens, they can influence operations based on the tokens’ repartition.
- [ ] **The total supply is sufficient.** Tokens with a low total supply can be easily manipulated.
- [ ] **The tokens are located in more than a few exchanges.** If all the tokens are in one exchange, a compromise of the exchange could compromise the contract relying on the token.
- [ ] **Users understand the risks associated with a large amount of funds or flash loans.** Contracts relying on the token balance must account for attackers with a large amount of funds or attacks executed through flash loans.
- [ ] **The token does not allow flash minting.** Flash minting can lead to substantial swings in the balance and the total supply, which necessitate strict and comprehensive overflow checks in the operation of the token.

### Known non-standard ERC20 tokens

The following tokens are known to be non-standard ERC20 tokens. They may have additional risks that must be covered.

| Token                                                                                                  | Issue               | Notes                                                                  |
| :----------------------------------------------------------------------------------------------------- | :------------------ | :--------------------------------------------------------------------- |
| [Basic Attention Token (BAT)](https://etherscan.io/token/0x0d8775f648430679a709e98d2b0cb6250d2887ef)   | NO_REVERT           |                                                                        |
| [Huobi Token (HT)](https://etherscan.io/token/0x6f259637dcd74c767781e37bc6133cd6a68aa161)              | NO_REVERT           |                                                                        |
| [Compound USD Coin (cUSDC)](https://etherscan.io/token/0x39aa39c021dfbae8fac545936693ac917d5e7563)     | NO_REVERT           |                                                                        |
| [Tether USD (USDT)](https://etherscan.io/token/0xdac17f958d2ee523a2206206994597c13d831ec7)             | MISSING_RETURN_DATA |                                                                        |
| [0x Protocol Token (ZRX)](https://etherscan.io/token/0xe41d2489571d322189246dafa5ebde1f4699f498)       | NO_REVERT           |                                                                        |
| [Binance Coin (BNB)](https://etherscan.io/token/0xB8c77482e45F1F44dE1745F52C74426C631bDD52)            | MISSING_RETURN_DATA | Only missing return data on `transfer`. `transferFrom` returns `true`. |
| [OMGToken (OMG)](https://etherscan.io/token/0xd26114cd6ee289accf82350c8d8487fedb8a0c07)                | MISSING_RETURN_DATA |                                                                        |
| [Wrapped Ether (WETH)](https://etherscan.io/token/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2)          | PERMIT_NOOP         | Includes a non-reverting `fallback` function.                          |
| [Amp (AMP)](https://etherscan.io/token/0xff20817765cb7f73d4bde2e66e067e58d11095c2)                     | TRANSFER_HOOKS      |                                                                        |
| [The Tokenized Bitcoin (imBTC)](https://etherscan.io/token/0x3212b29E33587A00FB1C83346f5dBFA69A458923) | TRANSFER_HOOKS      |                                                                        |

| Issue               | Description                                                                    | Notes                                                                                                                                                                                                                                                  |
| :------------------ | :----------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| NO_REVERT           | Does not revert when a transfer fails due to missing funds.                    | Protocols must check the return value in addition to the call success status.                                                                                                                                                                          |
| MISSING_RETURN_DATA | Does not return any data when transferring tokens.                             | Protocols that expect a return value when transferring tokens will revert. Solidity includes automatic checks on the return data size when calling `token.transfer`.                                                                                   |
| TRANSFER_HOOKS      | Includes [ERC777](https://eips.ethereum.org/EIPS/eip-777)-like transfer hooks. | Protocols that interact with tokens that include transfer hooks must be extra careful to protect against reentrant calls. This can also affect cross-protocol reentrant calls to `view` functions.                                                     |
| PERMIT_NOOP         | Does not revert when calling `permit`.                                         | Protocols that use [EIP-2612 permits](https://eips.ethereum.org/EIPS/eip-2612) should check that the token allowance has increased. See [Multichain's incident](https://media.dedaub.com/phantom-functions-and-the-billion-dollar-no-op-c56f062ae49f). |

Additional non-standard behavior might include:

- non-standard permits ([DAI](https://etherscan.io/token/0x6b175474e89094c44da98b954eedeac495271d0f))
- revert for approval of amount `>= 2^96 < 2^256 - 1` ([UNI](https://etherscan.io/token/0x1f9840a85d5af5bf1d1762f925bdaddc4201f984), [COMP](https://etherscan.io/token/0xc00e94cb662c3520282e6f5717214004a7f26888))
- fee on transfers
- do not reduce allowance when it is the maximum value
- do not require allowance for transfers from self
- upgradeable contracts (`USDC`)
- tokens with multiple proxy addresses

Refer to [d-xco/weird-erc20](https://github.com/d-xo/weird-erc20) for additional non-standard ERC20 tokens.

## ERC721 tokens

### ERC721 Conformity Checks

The behavior of certain contracts may differ from the original ERC specification. Conduct a manual review of the following conditions:

- [ ] **Transfers of tokens to the 0x0 address revert.** Several tokens allow transfers to 0x0 and consider tokens transferred to that address to have been burned; however, the ERC721 standard requires that such transfers revert.
- [ ] **`safeTransferFrom` functions are implemented with the correct signature.** Several token contracts do not implement these functions. A transfer of NFTs to one of those contracts can result in a loss of assets.
- [ ] **The `name`, `decimals`, and `symbol` functions are present if used.** These functions are optional in the ERC721 standard and may not be present.
- [ ] **If it is used, `decimals` returns a `uint8(0)`.** Other values are invalid.
- [ ] **The `name` and `symbol` functions can return an empty string.** This behavior is allowed by the standard.
- [ ] **The `ownerOf` function reverts if the `tokenId` is invalid or is set to a token that has already been burned.** The function cannot return 0x0. This behavior is required by the standard, but it is not always properly implemented.
- [ ] **A transfer of an NFT clears its approvals.** This is required by the standard.
- [ ] **The token ID of an NFT cannot be changed during its lifetime.** This is required by the standard.

### Common Risks of the ERC721 Standard

To mitigate the risks associated with ERC721 contracts, conduct a manual review of the following conditions:

- [ ] **The `onERC721Received` callback is taken into account.** External calls in the transfer functions can lead to reentrancies, especially when the callback is not explicit (e.g., in [`safeMint`](https://www.paradigm.xyz/2021/08/the-dangers-of-surprising-code/) calls).
- [ ] **When an NFT is minted, it is safely transferred to a smart contract.** If there is a minting function, it should behave similarly to safeTransferFrom and properly handle the minting of new tokens to a smart contract. This will prevent a loss of assets.
- [ ] **The burning of a token clears its approvals.** If there is a burning function, it should clear the token’s previous approvals.
