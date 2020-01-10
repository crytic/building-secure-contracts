

contract Token{

    mapping(address => uint) public balances;
    function airdrop() public{
        balances[msg.sender] = 1000;
    }

    function consume() public{ 
        require(balances[msg.sender]>0);
        balances[msg.sender] -= 1;
    }

    function backdoor() public{
        balances[msg.sender] += 1;
    }
}