// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.0;

import "./mintable.sol";

/// @dev Run the solution with
///      ```
///      solc-select use 0.5.0
///      echidna program-analysis/echidna/exercises/exercise3/solution.sol --contract TestToken
///      ```
contract TestToken is MintableToken {
    address echidna = msg.sender;

    constructor() public MintableToken(10000) {
        owner = echidna;
    }

    function echidna_test_balance() public view returns (bool) {
        return balances[msg.sender] <= 10000;
    }
}
