import "mintable.sol";

contract TestToken is MintableToken{

    address echidna_caller = 0x00a329c0648769a73afac7f9381e08fb43dbea70;

    constructor() MintableToken(10000){
        // initiate owner to echidna_caller
        owner = echidna_caller;
    }

    function echidna_test_balance() view public returns(bool){
        return balances[msg.sender] <= 10000;
    }

    // add the property

}
