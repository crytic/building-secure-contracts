// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.5.0;

contract Suicidal {
    function backdoor() public {
        selfdestruct(msg.sender);
    }
}
