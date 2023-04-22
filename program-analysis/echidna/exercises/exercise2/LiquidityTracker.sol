// SPDX-License-Identifier: GPL-3.0-only
// pragma experimental ABIEncoderV2;
pragma solidity 0.8.0;
// Inspired by Primitive v1 - reserves 
library LiquidityTracker {

    /// @notice                Stores global state of a pool
    /// @param reserveRisky    Risky token reserve
    /// @param reserveStable   Stable token reserve
    /// @param liquidity       Total supply of liquidity
    struct Data {
        uint128 reserveRisky;
        uint128 reserveStable;
        uint128 liquidity;
    }

    /// @notice                 Increases one reserve value and decreases the other
    /// @param  reserve         Reserve state to update
    /// @param  riskyForStable  Direction of swap
    /// @param  deltaIn         Amount of tokens paid, increases one reserve by
    /// @param  deltaOut        Amount of tokens sent out, decreases the other reserve by
    function swap(
        Data storage reserve,
        bool riskyForStable,
        uint256 deltaIn,
        uint256 deltaOut
    ) internal {
        if (riskyForStable) {
            reserve.reserveRisky += uint128(deltaIn);
            reserve.reserveStable -= uint128(deltaOut);
        } else {
            reserve.reserveRisky -= uint128(deltaOut);
            reserve.reserveStable += uint128(deltaIn);
        }
    }

    // this is a library, so assume that there is a public invokable wrapper that retrieves $$ 
    function add_funds(
        Data storage reserve,
        uint256 delRisky, 
        uint256 delStable
    ) internal returns (uint256 delLiquidity) { // when adding funds, all amounts should increase
        uint256 liquidity0 = (delRisky * reserve.liquidity) / uint256(reserve.reserveRisky); // calculate the risky token spot price 
        uint256 liquidity1 = (delStable * reserve.liquidity) / uint256(reserve.reserveStable); // calculate the stable token spot price
        delLiquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1; // min(risky,stable)

        reserve.reserveRisky += uint128(delRisky); 
        reserve.reserveStable += uint128(delStable); 
        reserve.liquidity += uint128(delLiquidity); 
    }

    // assume there exists a wrapper that handles the actual payment. 
    function remove_funds(
        Data storage reserve,
        uint256 delLiquidity
    ) internal returns (uint256 delRisky, uint256 delStable) { // when removing funds, all amounts should decrease 
		(delRisky, delStable) = getAmounts(reserve,delLiquidity); // calculate the amount of risky and stable tokens the incoming liquidity maps to     

        reserve.reserveRisky -= uint128(delRisky); 
        reserve.reserveStable -= uint128(delStable);
        reserve.liquidity -= uint128(delLiquidity);
    }

    /// @notice                 Calculates risky and stable token amounts of `delLiquidity`
    /// @param reserve          Reserve in memory to use reserves and liquidity of
    /// @param delLiquidity     Amount of liquidity to fetch underlying tokens of
    /// @return delRisky        Amount of P tokens controlled by `delLiquidity`
    /// @return delStable       Amount of stable tokens controlled by `delLiquidity`
    function getAmounts(Data memory reserve, uint256 delLiquidity)
        internal
        pure
        returns (uint256 delRisky, uint256 delStable)
    {
        uint256 liq = uint256(reserve.liquidity);
        delRisky = (delLiquidity * uint256(reserve.reserveRisky)) / liq;
        delStable = (delLiquidity * uint256(reserve.reserveStable)) / liq;
    }         
}
