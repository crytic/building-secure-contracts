// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.5.0;

contract Overflow {
    uint256 public sellerBalance = 0;

    function add(uint256 value) public returns (bool) {
        sellerBalance += value; // complicated math, possible overflow
    }
}
