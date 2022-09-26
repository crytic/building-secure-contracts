// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./side-entrance/SideEntranceLenderPool.sol";

contract E2E is IFlashLoanEtherReceiver {
    SideEntranceLenderPool pool;
    address ADDRESS_POOL = 0x1dC4c1cEFEF38a777b15aA20260a54E584b16C48;

    uint256 initialPoolBalance;

    bool action0_enabled;
    bool action1_enabled;
    uint256 action1_amount;

    constructor() payable {
        pool = SideEntranceLenderPool(ADDRESS_POOL);
        initialPoolBalance = address(pool).balance;
    }

    receive() external payable {}

    function setTestAction0(bool _enabled) public {
        action0_enabled = _enabled;
    }

    function setTestAction1(bool _enabled, uint256 _amount) public {
        action1_enabled = _enabled;
        action1_amount = _amount;
    }

    function execute() external payable override {
        if (action0_enabled) {
            pool.withdraw();
        }
        if (action1_enabled) {
            pool.deposit{value: action1_amount}();
        }
    }

    function flashLoan(uint256 _amount) public {
        pool.flashLoan(_amount);
    }

    function testPoolBalance() public view {
        assert(address(pool).balance >= initialPoolBalance);
    }
}
