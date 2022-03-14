import "mintable.sol";

/// @dev to run: $ echidna-test solution.sol --contract TestToken
contract TestToken is MintableToken {
    address echidna_caller = msg.sender;

    // update the constructor
    constructor() public MintableToken(10000) {
        owner = echidna_caller;
    }

    // add the property
    function echidna_test_balance() public view returns (bool) {
        return balances[msg.sender] <= 10000;
    }
}
