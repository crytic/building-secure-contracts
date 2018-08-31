pragma solidity ^0.4.15;

contract CrowdFundBad {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;

  function refundDos() public {
    for(uint i; i < refundAddresses.length; i++) {
      require(refundAddresses[i].send(refundAmount[refundAddresses[i]]));
    }
  }
}

contract CrowdFundPull {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;

  function withdraw() external {
    uint refund = refundAmount[msg.sender];
    refundAmount[msg.sender] = 0;
    msg.sender.send(refund);
  }
}


//This is safe against the list length being the source of block gas limit issues
//but is not safe in the scenario where the payee takes up a lot of gas, or is that
// not possible because send has a fixed gas limit?
contract CrowdFundSafe {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;
  uint256 nextIdx;
  
  function refundSafe() public {
    uint256 i = nextIdx;
    while(i < refundAddresses.length && msg.gas > 200000) {
      refundAddresses[i].send(refundAmount[i]);
      i++;
    }
    nextIdx = i;
  }
}
