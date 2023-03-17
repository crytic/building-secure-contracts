// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.0;

import "./mintable.sol";

/// @dev Run the template with
///      ```
///      solc-select use 0.5.0
///      echidna program-analysis/echidna/exercises/exercise3/template.sol --contract TestToken
///      ```
contract TestToken is MintableToken {
    address echidna = msg.sender;

    // TODO: update the constructor
    constructor(int256 totalMintable) public MintableToken(totalMintable) {}

    function echidna_test_balance() public view returns (bool) {
        // TODO: add the property
    }
}
