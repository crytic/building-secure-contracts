pragma solidity ^0.8.17;

contract Unprotected {
    address private owner;

    modifier onlyOwner {
        require(msg.sender==owner, "Permission denied");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // This function is missing the onlyOwner function modifier
    function changeOwner(address _newOwner) public {
       owner = _newOwner;
    }

    function changeOwnerFixed(address _newOwner) public onlyOwner {
       owner = _newOwner;
    }
}
