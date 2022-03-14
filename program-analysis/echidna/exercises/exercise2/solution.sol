import "token.sol";

/// @dev to run: $ echidna-test solution.sol
contract TestToken is Token {
    constructor() public {
        paused();
        owner = address(0x0); // lose ownership
    }

    // add the property
    function echidna_cannot_be_unpaused() public view returns (bool) {
        return is_paused == true;
    }
}
