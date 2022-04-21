pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "./UnstoppableLender.sol";
import "./ReceiverUnstoppable.sol";

/// @dev To run this contract: $ npx hardhat clean && npx hardhat compile --force && echidna-test . --contract UnstoppableEchidna --config contracts/unstoppable/config.yaml
contract UnstoppableEchidna {
    // We will send ETHER_IN_POOL to the flash loan pool.
    uint256 constant ETHER_IN_POOL = 1000000e18;
    // We will send INITIAL_ATTACKER_BALANCE to the attacker (which is the deployer) of this contract.
    uint256 constant INITIAL_ATTACKER_BALANCE = 100e18;

    DamnValuableToken token;
    UnstoppableLender pool;

    // Setup echidna test by deploying the flash loan pool, approving it for token transfers, sending it tokens, and sending the attacker some tokens.
    constructor() public payable {
        token = new DamnValuableToken();
        pool = new UnstoppableLender(address(token));
        token.approve(address(pool), ETHER_IN_POOL);
        pool.depositTokens(ETHER_IN_POOL);
        token.transfer(msg.sender, INITIAL_ATTACKER_BALANCE);
    }

    // This is the callback function for flash loan receivers.
    function receiveTokens(address tokenAddress, uint256 amount) external {
        require(msg.sender == address(pool), "Sender must be pool");
        // Return all tokens to the pool
        require(
            IERC20(tokenAddress).transfer(msg.sender, amount),
            "Transfer of tokens failed"
        );
    }

    // This is the Echidna property entrypoint.
    // We want to test whether flash loans can always be made.
    function echidna_testFlashLoan() public returns (bool) {
        pool.flashLoan(10);
        return true;
    }
}
