// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import "./token.sol";

contract TestToken is Token {
    function echidna_balance_under_1000() public view returns (bool) {
        return balances[msg.sender] <= 1000;
    }
}
