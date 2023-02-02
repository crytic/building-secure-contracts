// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "./level-utils/ERC20.sol";

contract NaughtCoin is ERC20 {
    // string public constant name = 'NaughtCoin';
    // string public constant symbol = '0x0' -> 'NTC';
    // uint public constant decimals = 18;
    uint256 public timeLock = block.timestamp + 10 * 365 days;
    uint256 public INITIAL_SUPPLY;
    address public player;

    // Note that the original symbol is changed from 0x0 to NTC
    // This is caused by https://github.com/crytic/echidna/issues/909
    constructor(address _player) ERC20("NaughtCoin", "NTC") {
        player = _player;
        INITIAL_SUPPLY = 1000000 * (10**uint256(decimals()));
        // _totalSupply = INITIAL_SUPPLY;
        // _balances[player] = INITIAL_SUPPLY;
        _mint(player, INITIAL_SUPPLY);
        emit Transfer(address(0), player, INITIAL_SUPPLY);
    }

    function transfer(address _to, uint256 _value)
        public
        override
        lockTokens
        returns (bool)
    {
        super.transfer(_to, _value);
    }

    // Prevent the initial owner from transferring tokens until the timelock has passed
    modifier lockTokens() {
        if (msg.sender == player) {
            require(block.timestamp > timeLock);
            _;
        } else {
            _;
        }
    }
}
