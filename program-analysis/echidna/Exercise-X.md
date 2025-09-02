# Naught Coin - exercise

This exercise is based on the [NaughtCoin - level 15 of the Ethernaut wargame](https://ethernaut.openzeppelin.com/level/15).

The first four exercises were focused on internal testing. This level is an excellent introduction to [external testing with Echidna](https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/common-testing-approaches.md#external-testing).  Since the `NaughtCoin` contract expects a `player` to be the owner of the NaughtCoin tokens, it is a good idea to go with an external setup. The `EchidnaTest` contract will act as a player. Such a setup allows us to relatively easy describe user2user or user2contract interactions.

### What you will learn

By completing this exercise, you will:

- Practice defining good invariants in plain English.
- Understand different ways of creating an external testing setup.
- Learn how to write simple properties and improve them over time.

### Exercise setup

The `NaughtCoin` contract has several dependencies. The directory structure that you should aim for looks like this:

```
src
├── NaughtCoin.sol
├── crytic
│   ├── ExternalTest.sol
│   └── config.yaml
└── level-utils
    ├── Context.sol
    ├── ERC20.sol
    ├── IERC20.sol
    └── IERC20Metadata.sol
```

Depending on your framework, the `NaughtCoin` contract will be in the `src` folder (Foundry) or `contracts` (Hardhat). OpenZeppelin dependencies are in the `level-utils` folder, and all Echidna-related files are in the `crytic` folder.

The config file used in this exercise looks as follows:

```yaml
testMode: assertion
corpusDir: "src/crytic/corpus"
testLimit: 50000 
multi-abi: true
```

The use of `assertions` is recommended for more flexibility when writing properties. The `multi-abi` allows Echidna to call any function, not just the properties you will write. Thanks to `multi-abi`, Echidna can figure out that it needs to call the `approve` or `increaseAllowance` before making a transfer. You should always collect a corpus, as it gives the necessary context to make sure that your properties are correct.

Read more about the [multi-abi](https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/using-multi-abi.md), [testing modes](https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/testing-modes.md) and [corpus](https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/collecting-a-corpus.md).

### Exercise goals

The main goal is to make the player's balance equal to `0`.  You might know the answer right away. However, the purpose of this exercise is to define the whole system using properties in an iterative way. Start small and see what you can find. Expand over time. Here are some steps that you may take:

1. Before writing any code, look at the NaughtCoin contract and think of 4-5 invariants that need to be held in this contract and write them down. The more, the better. You will be able to validate your assumptions about the system with Echidna. Be creative!
2. Create a simple `ExternalTest` contract with a proper state setup. Who is the player? Does he have the tokens?
3. Write a basic property to check if your code compiles, and Echidna is working as expected.
4. Start converting your plain English properties into code. Easy to implement properties first.
5. Remember, [the collected corpus is your friend](https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/collecting-a-corpus.md). Run Echidna on every code change and look at the corpus.
6. Refine your properties with better pre-conditions (a situation in which the property will be tested) and post-conditions (state checks after the action is performed). Everything that happens in between is an action.
7. Good luck!

### Solution steps

If you are stuck at any point, feel free to look at the following hints. You can reveal them one by one without spoiling the final solution. Try to complete this exercise on your own!

#### Example invariants in plain English

<details>
  <summary>1st invariant </summary>

   The token should be deployed `(address(token) != address(0))`.

</details>

<details>
  <summary>2nd invariant </summary>

   The player token balance should equal the initial supply if the current `block.timestamp < timelock`.

</details>

<details>
  <summary>3rd invariant </summary>

   The token transfer should fail if the current `block.timestamp < timelock`.

</details>

<details>
  <summary>4th invariant </summary>

   The `approve` function called by a `player` should never fail.

</details>

<details>
  <summary>5th invariant </summary>

   The player should not be able to burn (lock) tokens before the `timelock`.

</details>

<details>
  <summary>6th invariant</summary>

   The token transfer via `transferFrom` should fail if the current `block.timestamp < timelock` and/or spender has enough allowance.

</details>

#### External testing setup

<details>
  <summary>Example state setup</summary>

   ```solidity
   // SPDX-License-Identifier: MIT
  pragma solidity ^0.8.0;
  
  import {NaughtCoin} from "src/NaughtCoin.sol";
  
  contract ExternalTestSimple {
   address player;
      NaughtCoin public naughtCoin;
  
      constructor() {
       player = msg.sender;
          naughtCoin = new NaughtCoin(player);
      }
  }
   ```

</details>

<details>
  <summary>See if Echidna works as expected</summary>

   ```solidity
   function always_true() public pure {
        assert(true);
    }
   ```

</details>

#### Writing properties

<details>
  <summary>1st property</summary>

   ```solidity
   function token_is_deployed() public {
        assert(address(naughtCoin) != address(0));
    }
   ```

</details>

<details>
  <summary>2nd property</summary>

   ```solidity
   function sender_balance_is_equal_to_initial_supply() public {
        assert(naughtCoin.balanceOf(player) == naughtCoin.INITIAL_SUPPLY());
    }
   ```

</details>

<details>
  <summary>2nd property improved with pre-conditions</summary>
  
  In plain English we have defined this invariant as The player token balance should equal the initial supply if the current `block.timestamp < timelock`. The second part of this sentence specifies exactly when this property should be tested.
  
   ```solidity
   function sender_balance_is_equal_to_initial_supply() public {
        // pre-conditions
        uint256 currentTime = block.timestamp;
        if (currentTime < naughtCoin.timeLock()) {
         // post-conditions
            assert(naughtCoin.balanceOf(player) == naughtCoin.INITIAL_SUPPLY());
        }
    }
   ```

</details>

<details>
  <summary>3rd property</summary>

   The token transfer should fail if the current `block.timestamp < timelock`.

   For this property we need to create a second user. We will try to transfer tokens from `player` to `bob`.

   Add `bob` to your contract as `address bob;` and initialize his address in the constructor: `bob = address(0x123456)` to some random value.

   For this property we also need to add an additional pre-condition. We need to check player's and bob's balance before transferring tokens, to have something to compare to in the post-conditions.

   ```solidity
   function transfer_should_fail_before_timelock_period(uint256 amount) public {
        // pre-conditions
        uint256 playerBalanceBefore = naughtCoin.balanceOf(player);
        uint256 bobBalanceBefore = naughtCoin.balanceOf(bob);
        uint256 currentTime = block.timestamp;
        if (currentTime < naughtCoin.timeLock()) {
            // actions
            naughtCoin.transfer(bob, amount);
        }
        // post-conditions
        assert(
            naughtCoin.balanceOf(player) == playerBalanceBefore &&
                naughtCoin.balanceOf(bob) == bobBalanceBefore
        );
    }
   ```

Run Echidna and check the corpus. Is this a good property?

</details>

<details>
  <summary>Improving the 3rd property</summary>

   If you look at the corpus:

   ```
 34 | r   |     function transfer_should_fail_before_timelock_period() public {
 35 |     |         // pre-conditions
 36 | r   |         uint256 playerBalanceBefore = naughtCoin.balanceOf(player);
 37 | r   |         uint256 bobBalanceBefore = naughtCoin.balanceOf(bob);
 38 | r   |         uint256 currentTime = block.timestamp;
 39 | r   |         if (currentTime < naughtCoin.timeLock()) {
 40 |     |             // actions
 41 | r   |             naughtCoin.transfer(bob, 100);
 42 |     |         }
 43 |     |         // post-conditions
 44 |     |         assert(
 45 |     |             naughtCoin.balanceOf(player) == playerBalanceBefore &&
 46 |     |                 naughtCoin.balanceOf(bob) == bobBalanceBefore
 47 |     |         );
 48 |     |     }
 49 |     | }
   ```

   You can see that the transfer reverted as expected. But... Our post-conditions weren't checked. If you have read the [ERC20 spec](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md), you will know that the `transfer` function returns a status `boolean`. In the case of success, we can emit a special `AssertionFailed` event that won't stop the execution of the function. This way, our post-conditions will be checked.

- If `transfer` failed, that's okay. Keep going.
- If `transfer` succeeded, we don't want that, emit the `AssertionFailed` and check post-conditions as usual.

 Add the `event AssertionFailed(uint256 amount);` at the top of your contract.

   ```solidity
   function transfer_should_fail_before_timelock_period(uint256 amount)
        public
    {
        // pre-conditions
        uint256 playerBalanceBefore = naughtCoin.balanceOf(player);
        uint256 bobBalanceBefore = naughtCoin.balanceOf(bob);
        uint256 currentTime = block.timestamp;
        if (currentTime < naughtCoin.timeLock()) {
            // actions
            bool success1 = naughtCoin.transfer(bob, amount);
            if (success1) {
                emit AssertionFailed(amount);
            }
        }
        // post-conditions
        assert(
            naughtCoin.balanceOf(player) == playerBalanceBefore &&
                naughtCoin.balanceOf(bob) == bobBalanceBefore
        );
    }

   ```

Run Echidna and check the corpus. Now we have fully covered this property.

</details>

<details>
  <summary>4th property</summary>
  
   The `approve` function called by a `player` should not fail (even if the `player` currently does not have enough tokens). You can think of it as signing a blank cheque: "I as a player, allow Bob to spend the `amount` of my funds in one or more transactions".
   According to the [OZ ERC20 standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md) this function should only fail if the `0` address is involved.

   ```solidity
   function player_approval_should_not_fail(uint256 amount) public {
        // actions
        bool success1 = naughtCoin.approve(bob, amount);
        // post-conditions
        assert(success1);
    }
   ```

</details>

<details>
  <summary>5th property</summary>
  
  Player should not `burn` (lock) tokens before the `timeLock` period.
  The `ERC20` used in this exercise does not implement a public `burn` functionality, so the actual burning (removing from the total supply) is not possible.

  The only way a player could lock the tokens is by sending them to a non-existent address.

  This property would be invalidated if any of our previous property were invalidated (which seems to not be the case at the moment). Let's leave this property for now and move on.

</details>

<details>
  <summary>6th property</summary>
  
  The token transfer via `transferFrom` should fail if the current `block.timestamp < timelock` and/or spender has enough allowance.
  
  This property in its base form is the same as the one with `transfer` function.
  
   ```solidity
   function transfer_from_should_fail_before_timelock_period(uint256 amount)
        public
    {
        // pre-conditions
        uint256 playerBalanceBefore = naughtCoin.balanceOf(player);
        uint256 bobBalanceBefore = naughtCoin.balanceOf(bob);
        uint256 currentTime = block.timestamp;
        if (currentTime < naughtCoin.timeLock()) {
            // actions
            bool success1 = naughtCoin.transferFrom(player, bob, amount);
            if (success1) {
                emit AssertionFailed(amount);
            }
            // post-conditions
            assert(
                naughtCoin.balanceOf(player) == playerBalanceBefore &&
                    naughtCoin.balanceOf(bob) == bobBalanceBefore
            );
        }
    }
   ```

Run Echidna and see what you get. Echidna emits the `AssertionFailed` event with the `amount` of `0`. It means that the `transferFrom` succeeded. If you look at the corpus, you will see that our post-conditions were invalidated. Echidna found a way to change player's balance.

The property `playerBalance == InitialSupply` still holds. You need to guide Echidna a little bit more for it to invalidate this property.

Try to get into the mindset of exploring the system you are auditing. Since, we have discovered something new about the system, a `transferFrom` function does not fail, as we initially expected, the next logical step would be to test this functionality and make sure that it works properly.

Try to write a property for the `transferFrom` function.

</details>

<details>
  <summary>7th property</summary>
  
 There are no free tokens created in the `transferFrom` function.

 This property will check basic token arithmetics. The `transferFrom` works, so let's test that the user balances are updated correctly and reflect token transfers.
  
   ```solidity
   function no_free_tokens_in_transfer_from(uint256 amount) public {
        // pre-conditions
        uint256 playerBalanceBefore = naughtCoin.balanceOf(player);
        uint256 bobBalanceBefore = naughtCoin.balanceOf(bob);

        bool success1 = naughtCoin.transferFrom(player, bob, amount);
        require(success1, "transferFrom failed");

        // post-conditions
        assert(
            naughtCoin.balanceOf(player) == playerBalanceBefore - amount &&
                naughtCoin.balanceOf(bob) == bobBalanceBefore + amount
        );
    }
   ```

 If you run Echidna now, the `playerBalance == initialSupply` property fails.
 Echidna was able to find a call sequence to invalidate this property.

 ```solidity
  assertion in sender_balance_is_equal_to_initial_supply(): FAILED! with ErrorRevert                                   
  │                                                                                                                      │
  │ Call sequence:                                                                                                       │
  │ 1.increaseAllowance(0xa329c0648769a73afac7f9381e08fb43dbea72,11579208923731619542357098500868790785326998466564056403│
  │   9457584007913129639935) from: 0x0000000000000000000000000000000000030000 Time delay: 531977 seconds Block delay:   │
  │   12066                                                                                                              │
  │ 2.no_free_tokens_in_transfer_from(9) from: 0x0000000000000000000000000000000000010000 Time delay: 490448 seconds     │
  │   Block delay: 3753                                                                                                  │
  │ 3.sender_balance_is_equal_to_initial_supply() from: 0x0000000000000000000000000000000000030000 Time delay: 1 seconds │
  │   Block delay: 42595                                                                                                 │
  │ Event sequence:                                                                                                      │
  │ Panic(1)
 ```

</details>

#### Fixing a bug

Last step is to fix a bug that you have found. Try to fix it and re-run your properties. Check if they hold.

<details>
  <summary>Fixing a bug part 1</summary>

```solidity
function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public override lockTokens returns (bool) {
        super.transferFrom(_from, _to, _amount);
    }
```

If you run Echidna, you will see that the properties still fail. Why is that?

Add a `Player(address player)` event to your contract and emit it in your properties. Look at the call sequence.

</details>

<details>
  <summary>Fixing a bug part 2</summary>
  
The player's address is `0x30000`. Echidna is making calls from multiple accounts. It was able to increase the allowance of an address `0x10000` and make a call to `transferFrom(player, 0x10000, amount)`. This is expected!

The `lockTokens` modifier does not prevent others from making transfers, only the player is constrained.

```solidity
// Prevent the initial owner from transferring tokens until the timelock has passed
    modifier lockTokens() {
        if (msg.sender == player) {
            require(block.timestamp > timeLock);
            _;
        } else {
            _;
        }
    }
```

To test this you can change the modifier to be:

```solidity
// Prevent the initial owner from transferring tokens until the timelock has passed
    modifier lockTokens() {
        if (msg.sender == player) {
            require(block.timestamp > timeLock);
            _;
        } else {
            require(block.timestamp > timeLock);
            _;
        }
    }
```

No property fails now.

</details>

## Advanced Setup

This section will cover a more advanced setup for testing `NaughtCoin` `ERC20`.

### Prerequisites

Watch these two Echidna workshops in particular. The setup that we will use is explained in great detail there:

- [Intro to AMM's invariants](https://www.youtube.com/live/n0RaKKVTGvA?feature=share)
- [AMM fuzzing](https://www.youtube.com/live/OPDA0L9SeNI?feature=share)

This is not required, but the first two workshops explain the concept of fuzzing in much greater detail than any tutorial could. If you haven't watched them, do it, it's worth it.

- [Introduction to fuzzing](https://www.youtube.com/live/bhb_y80iF8w?feature=share)
- [Fuzzing Arithmetics](https://www.youtube.com/live/9P7sqE6hILM?feature=share)

### Why bother with a more complex setup?

Apart from a better code separation (grouping the code into logically separated pieces), an advanced setup comes with a couple of benefits:

- For complex codebases, you will often need to create some helper functions. Either to set the correct contract state ([This is what Justin does with the `_doApproval` function](https://www.youtube.com/watch?v=OPDA0L9SeNI&t=4237s)) or to remove code duplication in your properties. If you often repeat yourself and have the same logic in multiple properties, you can make your code [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) by moving some of that logic to the `Setup` contract.
- Creating a `User` contract gives you more flexibility when defining how users interact with each other or with the contract. If there are groups of users with certain privileges, you can create contracts like `Admin`, `Moderator`, `PriviledgedUser` etc. and give them access to certain functionalities.

### Exercise Setup

After you watch Justin's intro to AMM's invariants, try to create your own `Setup` contract in a separate file, `Setup.sol`.

The file structure remains the same as in the introductory section.

### Exercise Goals

1. Create the `Setup` contract with the appropriate state.
2. Re-write your properties from the previous section using `proxies`.

You can experiment with different ways of handling external calls. Instead of return value checks, you can use `try`/`catch`.

### Step by step solution

As before, you can reveal particular steps without spoiling the final solution.

<details>
  <summary>Setup contract</summary>

   This contract will be almost identical to what Justin did in the workshop.

   ```solidity
   // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {NaughtCoin} from "../NaughtCoin.sol";

contract User {
    function proxy(address target, bytes memory data)
        public
        returns (bool success, bytes memory returnData)
    {
        return target.call(data);
    }
}

contract Setup {
    NaughtCoin token;
    User player;
    User bob;

    constructor() {
        player = new User();
        bob = new User();
        token = new NaughtCoin(address(player));
    }

    function _between(
        uint256 amount,
        uint256 low,
        uint256 high
    ) internal pure returns (uint256) {
        return (low + (amount % (high - low + 1)));
    }
}
   ```

   In the introductory section we have used two addresses for `player` and `bob`. Now we are going to have two instances of the `User` contract: `player` and `bob`.

</details>

<details>
  <summary>Making sure that Echidna works</summary>
  
  ```solidity
  // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {NaughtCoin} from "src/NaughtCoin.sol";
import {Setup} from "./Setup.sol";

contract ExternalTestAdvanced is Setup {
    function always_true() public pure {
        assert(true);
    }
}
  ```

   Run Echidna and see if it starts.

</details>

<details>
  <summary>The 1st property</summary>
  
  The 1st property remains the same.
  
  ```solidity
  function token_should_be_deployed() public view {
        assert(address(token) != address(0));
    }
  ```

</details>

<details>
  <summary>The 2nd property</summary>
  
  The 2nd property remains the same.
  
  ```solidity
  function player_balance_is_equal_to_initial_supply() public view {
        assert(token.balanceOf(address(player)) == token.INITIAL_SUPPLY());
    }
  ```

</details>

<details>
  <summary>The 3rd property</summary>
  
  The 3rd property is slightly different. We have bounded the amount of tokens to be transferred between the value of `0` and the initial supply.

  ```solidity
   function token_transfer_should_fail_before_timelock_period(uint256 amount)
        public
    {
        amount = _between(amount, 0, token.INITIAL_SUPPLY());

        // pre-conditions
        uint256 currentTime = block.timestamp;
        uint256 playerBalanceBefore = token.balanceOf(address(player));
        uint256 bobBalanceBefore = token.balanceOf(address(bob));

        if (currentTime < token.timeLock()) {
            // action
            try
                player.proxy(
                    address(token),
                    abi.encodeWithSelector(
                        token.transfer.selector,
                        address(bob),
                        amount
                    )
                )
            returns (bool success, bytes memory returnData) {
                // optional log to silent unused return param warning
                // emit Log(returnData);
                assert(!success);
            } catch {
                /* reverted */
            }

            // post-conditions
            assert(token.balanceOf(address(player)) == playerBalanceBefore);
            assert(token.balanceOf(address(bob)) == bobBalanceBefore);
        }
    }
  ```
  
</details>

<details>
  <summary>The 4th property</summary>
  
  In the `try`/`catch` block we are making sure that the approval never reverts. This is not enough. You can enhance the post conditions to make sure that the `allowance` is updated.
  
  ```solidity
  function player_approval_should_never_fail(uint256 amount) public {
        // actions
        try
            player.proxy(
                address(token),
                abi.encodeWithSelector(
                    token.approve.selector,
                    address(bob),
                    amount
                )
            )
        {
            /* success */
        } catch {
            assert(false);
        }

        // post-conditions
        uint256 bobAllowanceAfter = token.allowance(
            address(player),
            address(bob)
        );
        assert(bobAllowanceAfter == amount);
    }
  ```
  
  You can also improve this property by allowing Echidna to approve different addresses.
  
  ```solidity
  function player_approval_should_never_fail(address person, uint256 amount)
        public
    {
        // pre-conditions
        if (person != address(0)) {
            // actions
            try
                player.proxy(
                    address(token),
                    abi.encodeWithSelector(
                        token.approve.selector,
                        person,
                        amount
                    )
                )
            {
                /* success */
            } catch {
                assert(false);
            }

            // post-conditions
            uint256 personAllowanceAfter = token.allowance(
                address(player),
                address(person)
            );
            assert(personAllowanceAfter == amount);
        }
    }
  ```

</details>

<details>
  <summary>The 6th property</summary>
  
  We are intentionally skipping the 5th property again.
  Echidna is able to invalidate the assertion inside the `try` block. The `transferFrom` function can be executed successfully. As you can see there is no need to set the `approval` manually. You can experiment with binding the `amount` to different values like `0` and `1`.
  
  Notice that we are using the `AssertionFailed` event to make sure that our post-conditions are checked. If instead you would have done `assert(success)`, Echidna would not be able to find out that it can decrease player balance.
  
  ```solidity
  function transfer_from_should_fail_before_timelock_period(uint256 amount)
        public
    {
        amount = _between(amount, 0, token.INITIAL_SUPPLY());

        // pre-conditions
        uint256 currentTime = block.timestamp;
        uint256 playerBalanceBefore = token.balanceOf(address(player));
        uint256 bobBalanceBefore = token.balanceOf(address(bob));

        if (currentTime < token.timeLock()) {
            // action
            try
                player.proxy(
                    address(token),
                    abi.encodeWithSelector(
                        token.transferFrom.selector,
                        address(player),
                        address(bob),
                        amount
                    )
                )
            returns (bool success, bytes memory returnData) {
                emit Log(returnData);
                if (success) {
                 emit AssertionFailed(amount);
                }
            } catch {
                /* reverted */
            }

            // post-conditions
            assert(token.balanceOf(address(player)) == playerBalanceBefore);
            assert(token.balanceOf(address(bob)) == bobBalanceBefore);
        }
    }
  ```

</details>

<details>
  <summary>The 7th property</summary>
  
  Thanks to this property Echidna is able to invalidate other properties. In the `try`/`catch` block we only really care about the success case (since we know that `transferFrom` can succeed). We are ensuring that internal accounting works properly.
  
  ```solidity
  function test_no_free_tokens_in_transfer_from(uint256 amount) public {
        // pre-conditions
        uint256 playerBalanceBefore = token.balanceOf(address(player));
        uint256 bobBalanceBefore = token.balanceOf(address(bob));

        // actions
        try
            player.proxy(
                address(token),
                abi.encodeWithSelector(
                    token.transferFrom.selector,
                    address(player),
                    address(bob),
                    amount
                )
            )
        returns (bool success, bytes memory returnData) {
            emit Log(returnData);
            require(success);
        } catch {}

        // post-conditions
        uint256 playerBalanceAfter = token.balanceOf(address(player));
        uint256 bobBalanceAfter = token.balanceOf(address(bob));
        assert(playerBalanceAfter == playerBalanceBefore - amount);
        assert(bobBalanceAfter == bobBalanceBefore + amount);
    }
  ```

</details>
