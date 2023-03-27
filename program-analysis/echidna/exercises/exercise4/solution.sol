/// @notice there are two ways to run this contract
/// @dev first way to run: $ echidna-test solution.sol --test-mode assertion --contract Token
/// @dev second way to run: $ echidna-test solution.sol --config config.yaml --contract Token
contract Ownership {
    address owner = msg.sender;

    function Owner() public {
        owner = msg.sender;
    }

    modifier isOwner() {
        require(owner == msg.sender);
        _;
    }
}

contract Pausable is Ownership {
    bool is_paused;
    modifier ifNotPaused() {
        require(!is_paused);
        _;
    }

    function paused() public isOwner {
        is_paused = true;
    }

    function resume() public isOwner {
        is_paused = false;
    }
}

contract Token is Pausable {
    mapping(address => uint256) public balances;

    constructor()  {
        balances[msg.sender] = 10000;
    }

    function transfer(address to, uint256 value) public ifNotPaused {
        require(msg.sender != to);
        require(balances[msg.sender] >= value);

        uint256 initial_balance_from = balances[msg.sender];
        uint256 initial_balance_to = balances[to];

        balances[msg.sender] -= value;
        balances[to] += value;

        assert(balances[msg.sender] <= initial_balance_from);
        assert(balances[to] >= initial_balance_to);

        /// you can use below assertion to check precisely.
        // assert(balances[msg.sender] == initial_balance_from - value);
        // assert(balances[to] == initial_balance_to + value);
    }
}
