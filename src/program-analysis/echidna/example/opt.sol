// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

contract TestDutchAuctionOptimization {
    int256 maxPriceDifference;

    function setMaxPriceDifference(uint256 startPrice, uint256 endPrice, uint256 startTime, uint256 endTime) public {
        if (endTime < (startTime + 900)) {
            revert();
        }
        if (startPrice <= endPrice) {
            revert();
        }
        uint256 numerator = (startPrice - endPrice) * (block.timestamp - startTime);
        uint256 denominator = endTime - startTime;
        uint256 stepDecrease = numerator / denominator;
        uint256 currentAuctionPrice = startPrice - stepDecrease;
        if (currentAuctionPrice < endPrice) {
            maxPriceDifference = int256(endPrice - currentAuctionPrice);
        }
        if (currentAuctionPrice > startPrice) {
            maxPriceDifference = int256(currentAuctionPrice - startPrice);
        }
    }

    function echidna_opt_price_difference() public view returns (int256) {
        return maxPriceDifference;
    }
}
