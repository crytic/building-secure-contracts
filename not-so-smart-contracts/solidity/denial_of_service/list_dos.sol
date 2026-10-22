pragma solidity ^0.8.17;

contract CrowdFundBad {
    address[] private refundAddresses;
    mapping(address => uint) public refundAmount;
    function badRefund() public {
        for(uint i; i < refundAddresses.length; i++) {
            // If one of the following transfers reverts, they all revert
            refundAddresses[i].transfer(refundAmount[refundAddresses[i]]);
        }
    }
}

// This is safe against the list length causing out of gas issues
// This is NOT safe against the payee causing the execution to revert
contract CrowdFundSafer {
    address[] private refundAddresses;
    mapping(address => uint) public refundAmount;
    uint256 public nextIdx;
    function refundSafe() public {
        uint256 i = nextIdx;
        // Refunds are only processed as long as sufficient gas remains
        while(i < refundAddresses.length && msg.gas > 200000) {
            refundAddresses[i].transfer(refundAmount[i]);
            i++;
        }
        nextIdx = i; // solhint-disable-line reentrancy
    }
}
