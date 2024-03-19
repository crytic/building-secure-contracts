pragma solidity ^0.8.17;

// Auction susceptible to DoS attack
contract InsecureAuction {
    address public currentWinner = address(0);
    uint public currentBid = 0;

    // Takes in bid, refunding the previous winner if they are outbid
    function bid() public payable {
        require(msg.value > currentBid, "Too little value to bid");
        // If the refund fails, the entire transaction reverts.
        // Therefore a bidder who always fails will win
        // E.g. if recipients fallback function is just revert()
        if (currentWinner != 0) {
            require(currentWinner.send(currentBid), "Send failure");
        }
        currentWinner = msg.sender; // solhint-disable-line reentrancy
        currentBid    = msg.value; // solhint-disable-line reentrancy
    }

}

// Auction that is NOT susceptible to DoS attack
contract SecureAuction {
    address public currentWinner;
    uint    public currentBid;

    // Store refunds in mapping to avoid DoS
    mapping(address => uint) public refunds;

    // Avoids "pushing" balance to users favoring "pull" architecture
    function bid() external payable {
        require(msg.value > currentBid, "Too little value to bid");
        if (currentWinner != 0) {
            refunds[currentWinner] += currentBid;
        }
        currentWinner = msg.sender;
        currentBid    = msg.value;
    }

    // Allows users to get their refund from auction
    function withdraw() public {
        // Do all state manipulation before external call to avoid reentrancy attack
        uint refund = refunds[msg.sender];
        refunds[msg.sender] = 0;
        msg.sender.transfer(refund); // even if this reverts, calls to bid() can still succeed
    }

}
