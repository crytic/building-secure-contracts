# Testing a Property with Echidna

**Table of contents:**

- [Introduction](#introduction)
- [Write a property](#write-a-property)
- [Initiate a contract](#initiate-a-contract)
- [Run Echidna](#run-echidna)
- [Summary: Testing a property](#summary-testing-a-property)


## Introduction

We will see how to test a smart contract with Echidna. The target is the following smart contract (*[example/token.sol](./example/token.sol)*):

```Solidity
   contract Token{
      mapping(address => uint) public balances;
      function airdrop() public{
          balances[msg.sender] = 1000;
     }
     function consume() public{
          require(balances[msg.sender]>0);
          balances[msg.sender] -= 1;
     }
     function backdoor() public{
          balances[msg.sender] += 1;
     }
   }
  
```

We will make the assumption that this token must have the following properties:

- Anyone can have at maximum 1000 tokens

- The token cannot be transferred (it is not an ERC20 token)

## Write a property

Echidna properties are Solidity functions. A property must:
- Have no argument
- Return true if it is successful
- Have its name starting with `echidna`

Echidna will:
- Automatically generate arbitrary transactions to test the property.
- Report any transactions leading a property to return false or throw an error. 
- Discard side-effect when calling a property (i.e. if the property changes a state variable, it is discarded after the test)

The following property checks that the caller has no more than 1000 tokens:

```Solidity
    function echidna_balance_under_1000() public view returns(bool){
         return balances[msg.sender] <= 1000;
    }
```

Use inheritance to separate your contract from your properties:

```Solidity
    contract TestToken is Token{
         function echidna_balance_under_1000() public view returns(bool){
               return balances[msg.sender] <= 1000;
          }
     }
```

*[example/testtoken.sol](./example/testtoken.sol)* implements the property and inherits from the token.

## Initiate a contract

Echidna needs a constructor without argument.
If your contract needs a specific initialization, you need to do it in the constructor.

There are some specific addresses in Echidna:

- `0x00a329c0648769A73afAc7F9381E08FB43dBEA72` which calls the constructor.

- `0x10000`, `0x20000`, and `0x00a329C0648769a73afAC7F9381e08fb43DBEA70` which randomly calls the other functions.

We do not need any particular initialization in our current example, as a result our constructor is empty.

## Run Echidna

Echidna is launched with:

```bash
$ echidna-test contract.sol
```

If contract.sol contains multiple contracts, you can specify the target:

```bash
$ echidna-test contract.sol --contract MyContract
```

## Summary: Testing a property

The following summarizes the run of echidna on our example:

```Solidity
     contract TestToken is Token{
         constructor() public {}
             function echidna_balance_under_1000() public view returns(bool){
                return balances[msg.sender] <= 1000;
             }
       }
```

```bash
$ echidna-test testtoken.sol --contract TestToken
...

echidna_balance_under_1000: failed!💥  
  Call sequence, shrinking (1205/5000):
    airdrop()
    backdoor()

...
```

Echidna found that the property is violated if `backdoor` is called.
