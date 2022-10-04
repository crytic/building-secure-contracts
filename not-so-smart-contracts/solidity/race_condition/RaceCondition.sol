pragma solidity ^0.8.17;

// https://github.com/ethereum/EIPs/issues/20
interface IERC20 {
    function totalSupply() public constant returns (uint totalSupply);
    function balanceOf(address _owner) public constant returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract RaceCondition{
    address private owner;
    uint public price;
    IERC20 public token;

    function RaceCondition(uint _price, IERC20 _token) public {
        owner = msg.sender;
        price = _price;
        token = _token;
    }

    // If the owner sees someone calls buy he can call changePrice to set a new price
    // If his transaction is mined first, he can receive more tokens than expected by the new buyer
    function buy(uint newPrice) external payable {
        require(msg.value >= price, "Insufficient value");
        // we assume that the RaceCondition contract has enough allowance
        token.transferFrom(msg.sender, owner, price);
        price = newPrice;
        owner = msg.sender;
    }

    function changePrice(uint newPrice) external {
        require(msg.sender == owner, "Permission denied");
        price = newPrice; 
    }

}
