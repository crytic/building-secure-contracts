pragma solidity ^0.7.6;

contract Overflow {
    uint private sellerBalance=0;

    function unsafeAdd(uint value) public returns (bool){
        sellerBalance += value; // possible overflow
        // the following assertion will revert if the above overflows
        // assert(sellerBalance >= value);
    }

    function safeAdd(uint value) public returns (bool){
        require(value + sellerBalance >= sellerBalance, "Overflow");
        sellerBalance += value;
    }
}
