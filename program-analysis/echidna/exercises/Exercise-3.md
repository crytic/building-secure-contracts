# Exercise 3

This exercise requires completing [exercise 1](./Exercise-1.md) and [exercise 2](./Exercise-2.md).

**Table of contents:**

- [Exercise 3](#exercise-3)
  - [Targeted contract](#targeted-contract)
  - [Testing with custom initialization](#testing-with-custom-initialization)
    - [Goals](#goals)
  - [Solution](#solution)

Join the team on Slack at: https://slack.empirehacking.nyc/ #ethereum

## Targeted contract

We will test the following contract _[token.sol](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/echidna/exercises/exercise3/token.sol)_:

```solidity
pragma solidity ^0.8.0;

/// @notice The issues from exercises 1 and 2 are fixed.

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

## Testing with custom initialization

Consider the following extension of the token (_[mintable.sol](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/echidna/exercises/exercise3/mintable.sol)_):

```solidity
pragma solidity ^0.8.0;

import "./token.sol";

contract MintableToken is Token {
    int256 public totalMinted;
    int256 public totalMintable;

    constructor(int256 totalMintable_) public {
        totalMintable = totalMintable_;
    }

    function mint(uint256 value) public onlyOwner {
        require(int256(value) + totalMinted < totalMintable);
        totalMinted += int256(value);

        balances[msg.sender] += value;
    }
}
```

The [version of token.sol](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/echidna/exercises/exercise3/token.sol#L1) contains the fixes from the previous exercises.

### Goals

- Create a scenario where `echidna (tx.origin)` becomes the owner of the contract at construction, and `totalMintable` is set to 10,000. Remember that Echidna needs a constructor without arguments.
- Add a property to check if `echidna` can mint more than 10,000 tokens.
- Once Echidna finds the bug, fix the issue, and re-try your property with Echidna.

The skeleton for this exercise is [template.sol](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/echidna/exercises/exercise3/template.sol):

````solidity
pragma solidity ^0.8.0;

import "./mintable.sol";

/// @dev Run the template with
///      ```
///      solc-select use 0.8.0
///      echidna program-analysis/echidna/exercises/exercise3/template.sol --contract TestToken
///      ```
contract TestToken is MintableToken {
    address echidna = msg.sender;

    // TODO: update the constructor
    constructor(int256 totalMintable) public MintableToken(totalMintable) {}

    function echidna_test_balance() public view returns (bool) {
        // TODO: add the property
    }
}
````

## Solution

This solution can be found in [solution.sol](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/echidna/exercises/exercise3/solution.sol).
