pragma solidity ^0.8.0;
import "./ERC20Permit.sol";

contract MockERC20Permit is ERC20Permit {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) ERC20Permit(_name, _symbol, _decimals) {}

    function mint(address _to, uint256 _value) external {
        _mint(_to, _value);
    }

    function burn(address _from, uint256 _value) external {
        _burn(_from, _value);
    }
}
