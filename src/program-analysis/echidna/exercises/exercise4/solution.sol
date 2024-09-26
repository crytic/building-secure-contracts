// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import "./token.sol";

/// @dev Run the solution with
///      ```
///      solc-select use 0.8.0
///      echidna program-analysis/echidna/exercises/exercise4/solution.sol --contract TestToken --test-mode assertion
///      ```
contract TestToken is Token {
    function transfer(address to, uint256 value) public override {
        uint256 oldBalanceFrom = balances[msg.sender];
        uint256 oldBalanceTo = balances[to];

        super.transfer(to, value);

        assert(balances[msg.sender] <= oldBalanceFrom);
        assert(balances[to] >= oldBalanceTo);
    }
}
