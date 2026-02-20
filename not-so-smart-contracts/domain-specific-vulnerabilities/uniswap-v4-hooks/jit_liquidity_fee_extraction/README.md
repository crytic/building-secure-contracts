# JIT Liquidity Fee Extraction

Fee redistribution mechanisms that donate to current LPs are exploitable through just-in-time concentrated liquidity.

## Description

Anti-MEV hooks that penalize adverse price movement by donating fees to the pool's active LPs are vulnerable to JIT attacks. An attacker can observe a pending swap, add highly concentrated liquidity at the current tick to capture the majority of the pool's active liquidity share, and trigger the fee donation. Since LP fees are distributed proportionally to active liquidity, the attacker -- who may hold 99% of active liquidity at the relevant tick -- captures 99% of the donated fees. The attacker then removes their liquidity, keeping the extracted fees.

The root cause is that `donate()` distributes to all active LPs at the current tick without regard for how long they have held their position. Any mechanism that distributes value proportionally to current liquidity is susceptible to this attack, because providing concentrated liquidity at a single tick is cheap relative to the fees captured.

## Exploit Scenario

An anti-sandwich hook donates penalty fees to pool LPs. Alice makes a swap that triggers a penalty donation of 1 ETH. Bob frontruns by adding concentrated liquidity at the current tick, representing 99% of active liquidity. The 1 ETH penalty is donated to the pool via `donate()`. Bob removes his liquidity and claims 0.99 ETH. His cost is two liquidity modification gas fees.

## Example

```solidity
contract VulnerableHook is BaseHook {
    function _afterSwap(PoolKey calldata key, IPoolManager.SwapParams calldata params, BalanceDelta delta)
        internal
    {
        uint160 priceAfter = _getCurrentPrice(key);
        bool priceWorsened = _detectAdverseMovement(priceAfter, params);

        if (priceWorsened) {
            uint256 penalty = _calculatePenalty(delta);
            // BUG: donate() distributes to ALL current LPs proportionally
            // JIT liquidity added moments ago captures the majority
            poolManager.donate(key, penalty, 0, "");
        }
    }
}
```

## Mitigations

- Track LP position age and exclude recently-added liquidity from fee distributions.
- Use time-weighted fee accrual instead of instant donation via `donate()`.
- Implement minimum LP duration requirements before positions are eligible for fee shares.
- Consider distributing fees through a vesting mechanism rather than direct pool donation.
