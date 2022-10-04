# Honeypot Collection

The Ethereum community has recently stumbled on a wide slew of honeypot smart contracts operating on the mainnet blockchain - something that we have been investigating for quite some time. They're designed to entice security researchers and developers to deposit Ethereum into the contract to obtain a chance to exploit 'easy vulnerabilities' in Solidity. However, once payment is deposited, the contracts will deploy subtle traps and quirks to lock out the user from successfully claiming the "prize."

The traps vary in sophistication. Our blockchain security research has turned up six fundamental archetypes that construct most of these honeypots. Some of these contracts are weeks old. A few were released before September, 2017. Many seem to be moderately successful - trapping around 0.1 ether and containing approximately 5 transactions on average. Yet for every successful trap, a large minority of contracts had no interaction at all. These 'failed honeypots' most likely served the original developers as a testing environment. The existence of these contracts must be taken into account by academic researchers quantifying the effectiveness of tools and analysis methods for the Ethereum blockchain, given the potential to skew research results.

Versions of the most recent compilers will emit warnings of most of these traps during compilation. However, some of the contracts rely on logic gaps in the solc compiler and the Solidity language itself.

## [GiftBox](GiftBox.sol)

Etherscan typically shows two transactions for a `GiftBox`-style honeypot. The first transaction is the contract creation, and the second is a call to a `setPassword` function that appears to set a "secret" `password` value. The secret can, of course, be easily observed on the blockchain, so the victim is tricked into submitting Ether with the correct value.

[Beware Of Eth Gifting Contracts Etherscan](https://www.blockchainsemantics.com/blog/beware-of-eth-gifting-contracts-etherscan/)

<details>
  <summary>Trap Spoiler</summary>
  Unbeknownst to the victim, the contract owner has already changed the stored hash of the secret, using an internal transaction with 0 value. Etherscan does not clearly display these 0 value internal transactions. The GiftBox owner might also be monitoring the mempool & would be prepared to front-run any withdrawals that submit the correct password;
</details>

## [King of the Hill](KOTH.sol)

At first glance this contract appears to be your average King of the Hill ponzi scheme. Participants contribute ether to the contract via the `stake()` function that keeps track of the latest `owner` and ether deposit that allowed them to become to the current owner. The `withdraw()` function employs an `onlyOwner` modifier, seemingly allowing only the last person recently throned the ability to transfer all funds out of the contract. Stumbling upon this contract on etherscan and seeing an existing balance, one might think that there is a chance to gain some easy ether by taking advantage of a quick `stake()` claim and subsequent `withdraw()`.

<details>
  <summary>Trap Spoiler</summary>
  The heart of the honeypot lies in the fact that the owner variable qualifying the `onlyOwner` modifier is not the one being reassigned in the `stake()` function. This is a particularly nasty bug that is made even more insidious by the fact that solc compilers version <0.6.0 will throw no error or warning indicating that the owner address is in fact being shadowed by the inheriting `CEOThrone` contract. By re-declaring the variable in the child's scope, the contract ensures that owner in `Ownable` is actually never reassigned at all and allows the original creator to dump all funds at their leisure. 
</details>

## [Lottery](Lottery.sol)

This appears to be a straightforward lottery that gives users a 1/8 chance of paying out 7x the ticket price. You know that [a contract can't securely use random numbers on-chain](../bad_randomness) so you recognize an opportunity to game this lottery contract & score an easy win. But this lottery is not as simple as it appears.

<details>
  <summary>Trap Spoiler</summary>
  Uninitialized structs default to acting like storage pointers for solidity versions <0.5.0 allowing the owner to use the `SeedComponents` variable to overwrite private variables.
</details>

## [Multiplicator](Multiplicator.sol)

Here is another ponzi-esque contract that promises to multiply your 'investment' by returning to you your initial deposit in addition to the current total balance of ether in the contract. The only condition is that the amount you send into the `multiplicate()` function must be greater than the current balance.

<details>
  <summary>Trap Spoiler</summary>
  The contract takes advantage of the fact that the global variable balance on the contract will always contain any ether sent to payable functions attached to `msg.value`. As a result, the condition `if(msg.value>=this.balance)` will always fail and the transfer will never occur. The `multiplicate()` function itself affirms the erroneous assumption by setting the transfer parameter as `this.balance + msg.value` (instead of only `this.balance`)
</details>

## [Private Bank](PrivateBank.sol)

Someone familiar with smart contract security and some of the more technical vulnerabilities might recognize that this contract is susceptible to a [classic reentrancy attack](https://github.com/trailofbits/not-so-smart-contracts/tree/master/reentrancy). It takes advantage of the low-level call in the function `cashOut()` by `msg.sender.call.value(_am)())`. Since the user balance is only decremented afterwards, the caller's callback function can call back into the method, allowing an attacker to continuously call `cashOut()` beyond what their initial balance should allow for. The only main difference is the addition of a `Log` class that seems to keep track of transitions.. Should you deposit and then try to use this reentrancy bug to `cashOut` multiple times?

<details>
  <summary>Trap Spoiler</summary>

  This honeypot takes advantage of the caller's assumptions, diverting attention away from the trap by seemingly including a reentrancy vulnerability. However, if you attempt to exploit this contract, you will find that your call to `cashOut` will fail every time.

  A closer inspection of the constructor will show that `TransferLog` is initialized from a user-supplied address. As long as the contract code at that location contains similar function signatures, the implementation of `AddMessage` can be completely different than the `Log` code contained in this source file. If this contract was deployed and only bytecode is available for the deployed `Log` contract, we can assume that it will revert or trap execution in a computationally expensive loop for everyone else but the owner.

</details>

## [VarLoop](VarLoop.sol)

The contract appears vulnerable to an old-fashioned constructor mismatch, allowing anyone to call the public method `Test1()` and double any ether they send to the function. The calculation involves a while loop which is strange, but the bounds conditions seem correct enough.

<details>
  <summary>Trap Spoiler</summary>

  This contract takes advantage of different semantics between Solidity and JavaScript to create type confusion. The var keyword allows the compiler to infer the type of the assignment when declaring a variable. In this instance, `i1` and `i2` are resolved to fact be `uint8`. As such, their maximum value will be 255 after which they overflow (because the solidity version is <0.8.0) causing the loop condition `if (i1 < i2)` to fail, sending at most 255 wei to the caller before terminating.

  Fortunately the var keyword was deprecated by the Solidity authors for versions 0.7.0 or greater.

  Implicit conversion of `var` type variable into `uint8` causes payment loop to short-circuit.

</details>
