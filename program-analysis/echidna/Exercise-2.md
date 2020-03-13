# Exercise 2

This exercise requires to finish the [exercise 1](Exercise-1.md).

**Table of contents:**

- [Targeted contract](#targeted-contract)
- [Exercise](#exercice)
- [Solution](#solution)

Join the team on Slack at: https://empireslacking.herokuapp.com/ #ethereum

## Targeted contract
  
We will test the following contract *[exercises/exercise2/token.sol](./exercises/exercise2/token.sol)*:

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
     
## Testing access control

### Goals

- Consider `paused()` to be called at deployment, and the ownership removed.
- Add a property to check that the contract cannot be unpaused.
- Once Echidna found the bug, fix the issue, and re-try your property with Echidna.

The skeleton for this exercise is (*[exercises/exercise2/template.sol](./exercises/exercise2/template.sol)*):

```Solidity
   import "token.sol";
   contract TestToken is Token {
      address echidna_caller = 0x00a329c0648769a73afac7f9381e08fb43dbea70;
      constructor(){
         paused(); // pause the contract
         owner = 0x0; // lose ownership
       }
         // add the property
     }
```

## Solution

 This solution can be found in [./exercises/exercise2/solution.sol](./exercises/exercise2/solution.sol)
