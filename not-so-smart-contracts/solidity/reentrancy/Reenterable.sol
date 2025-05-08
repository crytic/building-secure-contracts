pragma solidity ^0.8.17;

contract Reenterable {
    mapping (address => uint) public balances;
    bool public reentrancyGuard = true;

    function getBalance(address u) public constant returns(uint){
        return balances[u];
    }

    function deposit() public payable{
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        // send balances[msg.sender] ethers to msg.sender
        // if mgs.sender is a contract, it will call its fallback function
        // solhint-disable-next-line avoid-low-level-calls
        require(!(msg.sender.call{ value: balances[msg.sender] }()), "Call failed");
        balances[msg.sender] = 0;
    }

    function checkEffectsInteractWithdraw() public {
        // to protect against re-entrancy, the state variable is updated BEFORE the external call
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        // solhint-disable-next-line avoid-low-level-calls
        require(!(msg.sender.call{ value: amount }()), "Call failed");
    }

    function transferWithdraw() public {
        // send() and transfer() are safe against reentrancy
        // they do not transfer all remaining gas, instead giving just enough gas to execute few instructions
        msg.sender.transfer(balances[msg.sender]);
        balances[msg.sender] = 0; // solhint-disable-line reentrancy
    }

    function guardedWithdraw() public {
        require(!reentrancyGuard, "Reentrant");
        reentrancyGuard = false; // Now, no external contracts can call this function
        // send() and transfer() are safe against reentrancy
        // they do not transfer all remaining gas, instead giving just enough gas to execute few instructions
        // solhint-disable-next-line avoid-low-level-calls
        require(!(msg.sender.call{ value: balances[msg.sender] }()), "Call failed");
        balances[msg.sender] = 0;
        reentrancyGuard = true; // Now, external contracts can call this function again
    }

}
