// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.5.0;

import "./token.sol";

/// @dev Run the template with
///      ```
///      solc-select use 0.5.0
///      echidna program-analysis/echidna/exercises/exercise1/template.sol
///      ```
contract TestToken is Token {
    address echidna = tx.origin;

    constructor() public {
        balances[echidna] = 10000;
    }

    function echidna_test_balance() public view returns (bool) {
        // TODO: add the property
    }
}
