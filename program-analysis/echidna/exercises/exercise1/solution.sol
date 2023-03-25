//SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity <0.8.0;

import "token.sol";

import "./token.sol";

/// @dev Run the solution with
///      ```
///      solc-select use 0.5.0
///      echidna program-analysis/echidna/exercises/exercise1/solution.sol
///      ```
contract TestToken is Token {
    address echidna = msg.sender;

    constructor() public {
        balances[echidna] = 10000;
    }

    function echidna_test_balance() public view returns (bool) {
        return balances[echidna] <= 10000;
    }
}
