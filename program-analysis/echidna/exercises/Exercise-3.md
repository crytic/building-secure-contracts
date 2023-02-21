# Exercise 3

This exercise requires to finish [exercise 1](./Exercise-1.md) and [exercise 2](./Exercise-2.md)

**Table of contents:**

- [Targeted contract](#targeted-contract)
- [Exercise](#testing-with-custom-initialization)
- [Solution](#solution)

Join the team on Slack at: https://empireslacking.herokuapp.com/ #ethereum

## Targeted contract
  
We will test the following contract *[exercises/exercise3/token.sol](./exercises/exercise3/token.sol)*:

```Solidity
 contract Ownership{
    address owner = msg.sender;
    constructor() public {
        owner = msg.sender;
    }
     modifier isOwner(){
         require(owner == msg.sender);
         _;
      }
   }

  contract Pausable is Ownership{
     bool is_paused;
     modifier ifNotPaused(){
          require(!is_paused);
          _;
      }

      function paused() isOwner public{
          is_paused = true;
      }

      function resume() isOwner public{
          is_paused = false;
      }
   }

   contract Token is Pausable{
      mapping(address => uint) public balances;
      function transfer(address to, uint value) ifNotPaused public{
            require(balances[msg.sender] >= value);
            balances[msg.sender] -= value;
            balances[to] += value;
       }
    }

```

## Testing with custom initialization

Consider the following extension of the token (*[exercises/exercise3/mintable.sol](./exercises/exercise3/mintable.sol)*):

```Solidity
   import "token.sol";
   contract MintableToken is Token{
      int totalMinted;
      int totalMintable;

      constructor(int _totalMintable) public {
         totalMintable = _totalMintable;
      }

      function mint(uint value) isOwner() public{
          require(int(value) + totalMinted < totalMintable);
          totalMinted += int(value);
          balances[msg.sender] += value;
       }
    }
```

The [version of token.sol](./exercises/exercise3/token.sol#L1) contains the fixes of the previous exercises.

### Goals

- Create a scenario, where `echidna_caller (msg.sender)` becomes the owner of the contract at construction, and `totalMintable` is set to 10,000. Recall that Echidna needs a constructor without argument.
- Add a property to check if `echidna_caller` can mint more than 10,000 tokens.
- Once Echidna finds the bug, fix the issue, and re-try your property with Echidna.

The skeleton for this exercise is (*[exercises/exercise3/template.sol](./exercises/exercise3/template.sol)*):

```Solidity
   import "mintable.sol";
   contract TestToken is MintableToken {
      address echidna_caller = msg.sender;

      // update the constructor
      constructor() public {}

      // add the property
      function echidna_test_balance() public view returns (bool) {}
   }
```

## Solution

 This solution can be found in [./exercises/exercise3/solution.sol](./exercises/exercise3/solution.sol)
