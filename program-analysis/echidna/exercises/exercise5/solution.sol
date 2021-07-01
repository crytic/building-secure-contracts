pragma solidity ^0.6.0;

import "../DamnValuableToken.sol";
import "./UnstoppableLender.sol";
import "./ReceiverUnstoppable.sol";

contract UnstoppableEchidna {
    uint256 constant ETHER_IN_POOL = 1000000e18;
    uint256 constant INITIAL_ATTACKER_BALANCE = 100e18;

    DamnValuableToken token;
    UnstoppableLender pool;

    constructor() public payable {
        token = new DamnValuableToken();
        pool = new UnstoppableLender(address(token));
        token.approve(address(pool), ETHER_IN_POOL);
        pool.depositTokens(ETHER_IN_POOL);
        token.transfer(msg.sender, INITIAL_ATTACKER_BALANCE);
    }

    function receiveTokens(address tokenAddress, uint256 amount) external {
        require(msg.sender == address(pool), "Sender must be pool");
        // Return all tokens to the pool
        require(
            IERC20(tokenAddress).transfer(msg.sender, amount),
            "Transfer of tokens failed"
        );
    }

    function echidna_testFlashLoan() public returns (bool) {
        pool.flashLoan(10);
        return true;
    }
}
