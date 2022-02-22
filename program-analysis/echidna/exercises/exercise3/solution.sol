import "mintable.sol";


contract TestToken is MintableToken{

    address echidna_caller = msg.sender;
    constructor() MintableToken(10000) public {
        owner = echidna_caller;
    }

    // add the property
    function echidna_test_balance() view public returns(bool){
        return balances[msg.sender] <= 10000;
    }   



}

