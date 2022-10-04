pragma solidity ^0.4.18;

contract Test1 {
    address public owner = msg.sender;

    function withdraw() public payable {
        require(msg.sender == owner, "Permission denied");
        owner.transfer(this.balance);
    }

    fallback() payable {}

    // Old-school constructor
    // solhint-disable-next-line func-name-mixedcase
    function Test() public payable {
        if (msg.value >= 1 ether) {
            var i1 = 1;
            var i2 = 0;
            var amX2 = msg.value * 2;

            while(true) {
                if (i1 < i2) break;
                if (i1 > amX2) break;
                i2 = i1;
                i1++;
            }
            msg.sender.transfer(i2);
        }
    }

}
