# (Not So) Smart Contracts (Tick Math)

This section contains examples of common vulnerability patterns found in Uniswap V3/V4-style concentrated liquidity AMMs and protocols that integrate with them. These issues arise from the mathematical complexity of tick-based pricing, fee accounting, and TWAP oracle calculations.

## Features

Each not-so-smart-contract includes:

- Description of the vulnerability type
- Attack scenarios to exploit the vulnerability
- Solidity code examples demonstrating the flaw
- Recommendations to eliminate or mitigate the vulnerability

## Vulnerabilities

| Name                                                         | Description                                                                         |
| ------------------------------------------------------------ | ----------------------------------------------------------------------------------- |
| [slot0 Tick Misalignment](./slot0_tick_misalignment)         | Using `slot0.tick` instead of deriving from `sqrtPriceX96` causes off-by-one errors |
| [Negative Tick Rounding](./negative_tick_rounding)           | Solidity integer division truncates toward zero, producing incorrect TWAP ticks     |
| [Fee Growth Underflow](./fee_growth_underflow)               | Intentional underflow in fee accounting reverts in Solidity 0.8+                    |
| [Unsafe Integer Downcast](./unsafe_integer_downcast)         | Casting `int256` to `int24` without bounds checking causes tick wraparound          |
| [Missing Tick Spacing Validation](./tick_spacing_validation) | Positions with non-aligned ticks have zero liquidity or revert                      |
| [Tick Boundary Crossing](./tick_boundary_crossing)           | Incorrect tick iterator logic skips boundary ticks, causing liquidity underflow     |
| [TWAP Array Inversion](./twap_array_inversion)               | Subtracting tick cumulatives in wrong order inverts the price direction             |

## Credits

These examples are developed and maintained by **[Trail of Bits](https://www.trailofbits.com/)**.

Contact us if you need help with smart contract security.
