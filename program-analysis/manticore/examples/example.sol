// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.0;

contract Simple {
    function f(uint256 a) public payable {
        if (a == 65) {
            revert();
        }
    }
}
