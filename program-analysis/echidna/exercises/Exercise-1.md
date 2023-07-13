# Exercise 1

**Table of Contents:**

- [Exercise 1](#exercise-1)
  - [Targeted Contract](#targeted-contract)
  - [Testing a Token Balance](#testing-a-token-balance)
    - [Goals](#goals)
  - [Solution](#solution)

Join the team on Slack at: https://slack.empirehacking.nyc/ #ethereum

## Targeted Contract

We will test the following contract _[token.sol](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/echidna/exercises/exercise1/token.sol)_:

```solidity
pragma solidity ^0.8.0;

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

## Testing a Token Balance

### Goals

- Add a property to check that the address `echidna` cannot have more than an initial balance of 10,000.
- After Echidna finds the bug, fix the issue, and re-check your property with Echidna.

The skeleton for this exercise is (_[template.sol](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/echidna/exercises/exercise1/template.sol)_):

````solidity
pragma solidity ^0.8.0;

import "./token.sol";

/// @dev Run the template with
///      ```
///      solc-select use 0.8.0
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

This solution can be found in [solution.sol](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/echidna/exercises/exercise1/solution.sol).
