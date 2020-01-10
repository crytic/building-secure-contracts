import 'token.sol';

contract TestToken is Token{
    constructor() public {}

    function echidna_balance_under_1000() public view returns(bool){
        return balances[msg.sender] <= 1000;
    }

}