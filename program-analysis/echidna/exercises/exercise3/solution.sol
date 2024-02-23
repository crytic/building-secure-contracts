// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import "./mintable.sol";

/// @dev Run the solution with
///      ```
///      solc-select use 0.8.0
///      echidna program-analysis/echidna/exercises/exercise3/solution.sol --contract TestToken
///      ```
contract TestToken is MintableToken {
    address echidna = msg.sender;

    constructor() MintableToken(10_000) {
        owner = echidna;
    }

    function echidna_test_balance() public view returns (bool) {
        return balances[msg.sender] <= 10_000;
    }
}
