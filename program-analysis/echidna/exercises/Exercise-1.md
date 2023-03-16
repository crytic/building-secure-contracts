# Exercise 1

**Table of contents:**

- [Exercise 1](#exercise-1)
  - [Targeted contract](#targeted-contract)
  - [Testing a token balance](#testing-a-token-balance)
    - [Goals](#goals)
  - [Solution](#solution)

Join the team on Slack at: https://empireslacking.herokuapp.com/ #ethereum

## Targeted contract

We will test the following contract _[./exercise1/token.sol](./exercise1/token.sol)_:

```solidity
pragma solidity ^0.5.3;

contract Ownable {
    address public owner = msg.sender;

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: Caller is not the owner.");
        _;
    }
}

contract Pausable is Ownable {
    bool private _paused;

    function paused() public view returns (bool) {
        return _paused;
    }

    function pause() public onlyOwner {
        _paused = true;
    }

    function resume() public onlyOwner {
        _paused = false;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: Contract is paused.");
        _;
    }
}

contract Token is Ownable, Pausable {
    mapping(address => uint256) public balances;

    function transfer(address to, uint256 value) public whenNotPaused {
        balances[msg.sender] -= value;
        balances[to] += value;
    }
}
```

## Testing a token balance

### Goals

- Add a property to check that the address `echidna` cannot have more than an initial balance of 10000.
- Once Echidna finds the bug, fix the issue, and re-check your property with Echidna.

The skeleton for this exercise is (_[./exercise1/template.sol](./exercise1/template.sol)_):

````solidity
import "./token.sol";

/// @dev Run the template with
///      ```
///      solc-select use 0.5.3
///      echidna program-analysis/echidna/exercises/exercise1/template.sol
///      ```
contract TestToken is Token {
    address echidna = tx.origin;

    constructor() public {
        balances[echidna] = 10000;
    }

    function echidna_test_balance() public view returns (bool) {
        // TODO: add the property
    }
}
````

## Solution

This solution can be found in [./exercise1/solution.sol](./exercise1/solution.sol)
