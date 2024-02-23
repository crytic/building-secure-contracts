// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import "./token.sol";

/// @dev Run the solution with
///      ```
///      solc-select use 0.8.0
///      echidna program-analysis/echidna/exercises/exercise1/solution.sol
///      ```
contract TestToken is Token {
    address echidna = msg.sender;

    constructor() {
        balances[echidna] = 10_000;
    }

    function echidna_test_balance() public view returns (bool) {
        return balances[echidna] <= 10000;
    }
}
