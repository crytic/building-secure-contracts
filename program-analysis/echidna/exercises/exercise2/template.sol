// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.5.0;

import "./token.sol";

/// @dev Run the template with
///      ```
///      solc-select use 0.5.0
///      echidna program-analysis/echidna/exercises/exercise2/template.sol
///      ```
contract TestToken is Token {
    constructor() public {
        pause(); // pause the contract
        owner = address(0); // lose ownership
    }

    function echidna_cannot_be_unpause() public view returns (bool) {
        // TODO: add the property
    }
}
