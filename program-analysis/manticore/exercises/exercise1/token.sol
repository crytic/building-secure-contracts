pragma solidity ^0.5.3;

contract CryticCoin{

    mapping(address => uint) balances; 
    uint decimals = 1**18;
    uint MAX_SUPPLY =  100 ether;
    event Mint(address indexed destination, uint amount);

    /// @notice Allow users to buy token. 1 ether = 10 tokens
    /// @param tokens The numbers of token to buy
    /// @dev Users can send more ether than token to be bought, to give gifts to the team. 
    function buy(uint tokens) public payable{
        _valid_buy(tokens, msg.value);
        _mint(msg.sender, tokens);
    }


    /// @notice Check if a buy is valid
    /// @param tokens_amount tokens amount
    /// @param wei_amount wei amount
    function is_valid_buy(uint tokens_amount, uint wei_amount) external view returns(bool){
        _valid_buy(tokens_amount, wei_amount);
        return true;
    }

    /// @notice Mint tokens
    /// @param addr The address holding the new token
    /// @param value The amount of token to be minted
    /// @dev This function performed no check on the caller. Must stay internal
    function _mint(address addr, uint value) internal{
        balances[addr] = safeAdd(balances[addr], value);
        emit Mint(addr, value);
    }

    /// @notice Compute the amount of token to be minted. 1 ether = 10 tokens
    /// @param desired_tokens The number of tokens to buy
    /// @param wei_sent The ether value to be converted into token
    function _valid_buy(uint desired_tokens, uint wei_sent) internal view{
        uint required_wei_sent = (desired_tokens / 10) * decimals; 
        require(wei_sent >= required_wei_sent);
    }

    /// @notice Add two values. Revert if overflow
    function safeAdd(uint a, uint b) pure internal returns(uint){
        if(a + b <= a){
            revert();
        }
        return a + b;
    }

}
