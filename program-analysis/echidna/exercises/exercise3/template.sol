import "mintable.sol";

contract TestToken is MintableToken {
    address echidna_caller = msg.sender;

    // update the constructor
    constructor() public {}

    // add the property
    function echidna_cannot_mint_more() public view returns (bool) {}
}
