// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

import "./side-entrance/SideEntranceLenderPool.sol";

contract PoolDeployer {
    function deployNewPool() public payable returns (SideEntranceLenderPool) {
        SideEntranceLenderPool p;
        p = new SideEntranceLenderPool();
        p.deposit{value: msg.value}();

        return p;
    }
}

contract SideEntranceEchidna is IFlashLoanEtherReceiver {
    SideEntranceLenderPool pool;

    uint256 initialPoolBalance;

    bool enableWithdraw;
    bool enableDeposit;
    uint256 depositAmount;

    constructor() payable {
        require(msg.value == 1000 ether);

        PoolDeployer p = new PoolDeployer();

        pool = p.deployNewPool{value: 1000 ether}();
        initialPoolBalance = address(pool).balance;
    }

    receive() external payable {}

    function setEnableWithdraw(bool _enabled) public {
        enableWithdraw = _enabled;
    }

    function setEnableDeposit(bool _enabled, uint256 _amount) public {
        enableDeposit = _enabled;
        depositAmount = _amount;
    }

    function execute() external payable override {
        if (enableWithdraw) {
            pool.withdraw();
        }
        if (enableDeposit) {
            pool.deposit{value: depositAmount}();
        }
    }

    function flashLoan(uint256 _amount) public {
        pool.flashLoan(_amount);
    }

    function testPoolBalance() public view {
        assert(address(pool).balance >= initialPoolBalance);
    }
}
