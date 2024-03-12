# Known non-standard ERC20 tokens

The following tokens are known to be non-standard ERC20 tokens. They may have additional risks that must be covered.

## Missing Revert

These tokens do not revert when a transfer fails, e.g. due to missing funds. Protocols that integrate these tokens must include a check for the transfer function's returned boolean success status and handle the failure case appropriately.

| Token                                                                                                | Notes |
| :--------------------------------------------------------------------------------------------------- | :---- |
| [Basic Attention Token (BAT)](https://etherscan.io/token/0x0d8775f648430679a709e98d2b0cb6250d2887ef) |       |
| [Huobi Token (HT)](https://etherscan.io/token/0x6f259637dcd74c767781e37bc6133cd6a68aa161)            |       |
| [Compound USD Coin (cUSDC)](https://etherscan.io/token/0x39aa39c021dfbae8fac545936693ac917d5e7563)   |       |
| [0x Protocol Token (ZRX)](https://etherscan.io/token/0xe41d2489571d322189246dafa5ebde1f4699f498)     |       |

## Transfer Hooks

These tokens include [ERC777](https://eips.ethereum.org/EIPS/eip-777)-like transfer hooks. Protocols that interact with tokens that include transfer hooks must be extra careful to protect against reentrant calls when dealing with these tokens, because control is handed back to the caller upon transfer. This can also affect cross-protocol reentrant calls to `view` functions.

| Token                                                                                                  | Notes |
| :----------------------------------------------------------------------------------------------------- | :---- |
| [Amp (AMP)](https://etherscan.io/token/0xff20817765cb7f73d4bde2e66e067e58d11095c2)                     |       |
| [The Tokenized Bitcoin (imBTC)](https://etherscan.io/token/0x3212b29E33587A00FB1C83346f5dBFA69A458923) |       |

## Missing Return Data / Transfer Success Status

These tokens do not return any data from the external call when transferring tokens. Protocols using an interface that specifies a return value when transferring tokens will revert. Solidity includes automatic checks on the return data size when decoding return values of an expected size.

| Token                                                                                       | Notes                                                                  |
| :------------------------------------------------------------------------------------------ | :--------------------------------------------------------------------- |
| [Binance Coin (BNB)](https://etherscan.io/token/0xB8c77482e45F1F44dE1745F52C74426C631bDD52) | Only missing return data on `transfer`. `transferFrom` returns `true`. |
| [OMGToken (OMG)](https://etherscan.io/token/0xd26114cd6ee289accf82350c8d8487fedb8a0c07)     |                                                                        |
| [Tether USD (USDT)](https://etherscan.io/token/0xdac17f958d2ee523a2206206994597c13d831ec7)  |                                                                        |

## Permit No-op

Does not revert when calling `permit`. Protocols that use [EIP-2612 permits](https://eips.ethereum.org/EIPS/eip-2612) should check that the token allowance has increased or is sufficient. See [Multichain's incident](https://media.dedaub.com/phantom-functions-and-the-billion-dollar-no-op-c56f062ae49f).

| Token                                                                                         | Notes                                         |
| :-------------------------------------------------------------------------------------------- | :-------------------------------------------- |
| [Wrapped Ether (WETH)](https://etherscan.io/token/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2) | Includes a non-reverting `fallback` function. |

## Additional Non-standard Behavior

Additional non-standard token behavior that could be problematic includes:

- fee on transfers
- upgradeable contracts ([USDC](https://etherscan.io/token/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48))
- tokens with multiple address entry-points to the same accounting state
- non-standard decimals ([USDC](https://etherscan.io/token/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48): 6)
- non-standard permits ([DAI](https://etherscan.io/token/0x6b175474e89094c44da98b954eedeac495271d0f))
- do not reduce allowance when it is the maximum value
- do not require allowance for transfers from self
- revert for approval of large amounts `>= 2^96 < 2^256 - 1` ([UNI](https://etherscan.io/token/0x1f9840a85d5af5bf1d1762f925bdaddc4201f984), [COMP](https://etherscan.io/token/0xc00e94cb662c3520282e6f5717214004a7f26888))

Refer to [d-xo/weird-erc20](https://github.com/d-xo/weird-erc20) for additional non-standard ERC20 tokens.
