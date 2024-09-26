// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.5.0;

contract Token {
    mapping(address => uint256) public balances;

    constructor() public {
        balances[msg.sender] = 100;
    }

    function transfer(address to, uint256 val) public {
        // check for overflow
        if (balances[msg.sender] >= balances[to]) {
            balances[msg.sender] -= val;
            balances[to] += val;
        }
    }
}
