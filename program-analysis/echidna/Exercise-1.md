# Exercise 1

**Table of contents:**

- [Targeted contract](#Targeted-contract)
- [Exercise](#exercise)
- [Solution](#solution)

Join the team on Slack at: https://empireslacking.herokuapp.com/ #ethereum

## Targeted contract
  
We will test the following contract *[exercises/exercise1/token.sol](exercises/exercise1/token.sol)*:

```Solidity
 contract Ownership{
    address owner = msg.sender;
    function Owner(){
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
           balances[msg.sender] -= value;
           balances[to] += value;
       }
    }

```

## Testing a token balance

### Goals

- Add a property to check that `echidna_caller` cannot have more than an initial balance of 10000.
- Once Echidna finds the bug, fix the issue, and re-check your property with Echidna.

The skeleton for this exercise is (*[exercises/exercise1/template.sol](./exercises/exercise1/template.sol)*):

```Solidity
     import "token.sol";
     contract TestToken is Token {
       address echidna_caller = 0x00a329c0648769a73afac7f9381e08fb43dbea70;

        constructor() public{
            balances[echidna_caller] = 10000;
         }
         // add the property
      }
 ```

## Solution

This solution can be found in [exercises/exercise1/solution.sol](./exercises/exercise1/solution.sol)
