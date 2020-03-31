# Exercise 4

**Table of contents:**

- [Targeted contract](#targeted-contract)
- [Exercise](#exercise)
- [Solution](#solution)

This exercise is based on the tutorial [How to test assertions](./assertion-checking.md).

Join the team on Slack at: https://empireslacking.herokuapp.com/ #ethereum

## Targeted contract

We will test the following contract *[exercises/token.sol](exercises/token.sol)*:

```Solidity
 contract Ownership{
    address owner = msg.sender;
    function Owner() public{
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

## Exercise

### Goals

Add asserts to ensure that after calling `transfer`:

- `msg.sender` must have its initial balance or less.
- `to` must have its initial balance or more.

Once Echidna found the bug, fix the issue, and re-try your assertion with Echidna.

This exercise is similar to the [first one](Exercise-1.md), but using assertions instead of explicit properties.  
However, in this exercise, it is easier to modify the original token contract (*[exercises/exercise4/token.sol](./exercises/exercise4/token.sol)*).

## Solution

This solution can be found in [exercises/exercise4/solution.sol](./exercises/exercise4/solution.sol)
