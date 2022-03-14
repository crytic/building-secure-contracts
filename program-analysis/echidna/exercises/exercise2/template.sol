import "token.sol";

contract TestToken is Token {
    constructor() public {
        paused(); // pause the contract
        owner = address(0x0); // lose ownership
    }

    // add the property
    function echidna_cannot_be_unpaused() public view returns (bool) {}
}
