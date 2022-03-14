import "mintable.sol";

contract TestToken is MintableToken {
    address echidna_caller = msg.sender;

    // update the constructor
    constructor() public {}

    // add the property
    function echidna_test_balance() public view returns (bool) {}
}
