pragma solidity ^0.6.0;

import "./NaiveReceiverLenderPool.sol";
import "./FlashLoanReceiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract NaiveReceiverEchidna {
    using Address for address payable;

    uint256 constant ETHER_IN_DEPLOYER = 10000e18;
    uint256 constant ETHER_IN_POOL = 1000e18;

    NaiveReceiverLenderPool pool;
    FlashLoanReceiver receiver;

    constructor() public payable {
        pool = new NaiveReceiverLenderPool();
        payable(address(pool)).sendValue(ETHER_IN_POOL);
    }

    function receiveEther(uint256 fee) public payable {
        require(msg.sender == address(pool), "Sender must be pool");

        uint256 amountToBeRepaid = msg.value + fee;

        require(
            address(this).balance >= amountToBeRepaid,
            "Cannot borrow that much"
        );

        // Return funds to pool
        payable(address(pool)).sendValue(amountToBeRepaid);
    }

    function echidna_testBalanceInv() public view returns (bool) {
        return address(this).balance >= ETHER_IN_DEPLOYER - ETHER_IN_POOL;
    }
}
