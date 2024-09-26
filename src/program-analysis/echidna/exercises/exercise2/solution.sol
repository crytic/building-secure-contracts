// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import "./token.sol";

/// @dev Run the solution with
///      ```
///      solc-select use 0.8.0
///      echidna program-analysis/echidna/exercises/exercise1/solution.sol
///      ```
contract TestToken is Token {
    constructor() {
        pause(); // pause the contract
        owner = address(0); // lose ownership
    }

    function echidna_no_transfer() public view returns (bool) {
        return paused() == true;
    }
}
