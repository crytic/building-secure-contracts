# Exercise 4

**Table of contents:**

- [Exercise 4](#exercise-4)
  - [Targeted contract](#targeted-contract)
  - [Exercise](#exercise)
    - [Goals](#goals)
  - [Solution](#solution)

This exercise is based on the tutorial [How to test assertions](../basic/assertion-checking.md).

Join the team on Slack at: https://slack.empirehacking.nyc/ #ethereum

## Targeted contract

We will test the following contract, _[token.sol](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/echidna/exercises/exercise4/token.sol)_:

```solidity
pragma solidity ^0.8.0;

contract Ownable {
    address public owner = msg.sender;

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: Caller is not the owner");
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
        require(!_paused, "Pausable: Contract is paused");
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

## Exercise

### Goals

Add assertions to ensure that after calling `transfer`:

- `msg.sender` must have its initial balance or less.
- `to` must have its initial balance or more.

Once Echidna finds the bug, fix the issue, and re-try your assertion with Echidna.

This exercise is similar to the [first one](Exercise-1.md), but it uses assertions instead of explicit properties.

The skeleton for this exercise is ([template.sol](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/echidna/exercises/exercise4/template.sol)):

````solidity
pragma solidity ^0.8.0;

import "./token.sol";

/// @dev Run the template with
///      ```
///      solc-select use 0.8.0
///      echidna program-analysis/echidna/exercises/exercise4/template.sol --contract TestToken --test-mode assertion
///      ```
contract TestToken is Token {
    function transfer(address to, uint256 value) public {
        // TODO: include `assert(condition)` statements that
        // detect a breaking invariant on a transfer.
        // Hint: you may use the following to wrap the original function.
        super.transfer(to, value);
    }
}
````

## Solution

This solution can be found in [solution.sol](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/echidna/exercises/exercise4/solution.sol)
