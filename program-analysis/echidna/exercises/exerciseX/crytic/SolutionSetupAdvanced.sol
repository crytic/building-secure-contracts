// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {NaughtCoin} from "../NaughtCoin.sol";

contract User {
    function proxy(address target, bytes memory data)
        public
        returns (bool success, bytes memory returnData)
    {
        return target.call(data);
    }
}

contract Setup {
    NaughtCoin token;
    User player;
    User bob;

    constructor() {
        player = new User();
        bob = new User();
        token = new NaughtCoin(address(player));
    }

    function _between(
        uint256 amount,
        uint256 low,
        uint256 high
    ) internal pure returns (uint256) {
        return (low + (amount % (high - low + 1)));
    }
}
