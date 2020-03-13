import "token.sol";

contract TestToken is Token {

    constructor() public{
        paused();
        owner = address(0x0); // lose ownership
    }

    // add the property
    function echidna_no_transfer() public view returns(bool){

    }


}

