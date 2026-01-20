pragma solidity ^0.8.17;

contract Owned {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "permission denied");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

interface TokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external;
}

contract TokenERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18; // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor(string tokenName, string tokenSymbol) {
        name = tokenName;
        symbol = tokenSymbol;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender], "Insuffient allowance");
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. 
        require(_to != 0x0, "Invalid address");
        // Check if the sender has enough
        require(balanceOf[_from] >= _value, "Insufficient balance");
        // Check for overflows
        require(balanceOf[_to] + _value > balanceOf[_to], "Overflow");
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

}

contract MyAdvancedToken is Owned, TokenERC20 {
    mapping (address => bool) public frozenAccount;

    constructor(string tokenName, string tokenSymbol) {
        TokenERC20(tokenName, tokenSymbol);
    }

    // Internal transfer, only can be called by this contract
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0, "Invalid address");
        require (balanceOf[_from] >= _value, "Insufficient Balance");
        require (balanceOf[_to] + _value >= balanceOf[_to], "Overflow");
        require(!frozenAccount[_from], "Frozen sender");
        require(!frozenAccount[_to], "Frozen recipient");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    // Buy tokens from contract by sending ether
    function buy() public payable {
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        totalSupply += amount; // Increase total supply whenever new tokens are purchased
        _transfer(address(0x0), msg.sender, amount);
    }

    // Migration function
    // NOTE: this function will fail if this contract receives ether outside of a call to buy()
    function migrateAndDestroy() public onlyOwner {
        assert(this.balance == totalSupply); // ERROR this can be DoS'd
        selfdestruct(owner);
    }

    // The following attempts to prevent anyone from sending ether to this contract
    // BUT even with the following functions in place, this contract can still receive ether via:
    // - a miner setting this address as it's beneficiary and then mining a block
    // - a contract selfdestructs and sets this address as it's beneficiary
    receive() public payable {
        revert("Only send ether through buy()");
    }
    fallback() public payable {
        revert("Only send ether through buy()");
    }

}
