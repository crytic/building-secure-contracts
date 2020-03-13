# Exercise 4

**Table of contents:**

- [Targeted contract](#Targeted-contract)
- [Exercise](#exercise)
- [Solution](#solution)

Join the team on Slack at: https://empireslacking.herokuapp.com/ #ethereum

## Targeted contract

We will test the following contract *[exercises/token.sol](exercises/token.sol)*:

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

## Testing token's balance

### Goals

- Add an assert to check that `echidna_caller` cannot have more than an initial balance of 10000.
- Once Echidna found the bug, fix the issue, and re-try your property with Echidna.

This exercise is similar to the [first one](Exercise-1.md), but using assertions instead of explicit properties.  
The skeleton for this exercise is (*[exercises/exercise4/template.sol](./exercises/exercise4/template.sol)*):

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

This solution can be found in [exercises/exercise4/solution.sol](./exercises/exercise4/solution.sol)
