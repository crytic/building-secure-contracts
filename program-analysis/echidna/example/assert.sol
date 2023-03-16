// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.3;

contract Incrementor {
    uint256 private counter = 2 ** 200;

    function inc(uint256 val) public returns (uint256) {
        uint256 tmp = counter;
        counter += val;
        assert(tmp <= counter);
        return (counter - tmp);
    }
}
