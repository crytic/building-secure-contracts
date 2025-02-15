# Denial of Service

A malicious contract can permanently stall another contract that calls it by failing in a strategic way. In particular, contracts that bulk perform transactions or updates using a `for` loop can be DoS'd if a call to another contract or `transfer` fails during the loop. 

## Attack Scenarios

- Auction contract where the previous winner must be reimbursed when they are outbid. If the call refunding the previous winner continuously fails, the auction is stalled and they become the de facto winner. It's better to use a pull-pattern that flags funds as eligible for withdrawal. See examples of an [insecure](auction.sol#L4) and [secure](auction#L24) version of this auction pattern.
- Contract iterates through an array to pay back its users. If one `transfer` fails in the middle of a `for` loop all reimbursements fail. See [this insecure example](list_dos.sol#L3) for an example of doing this wrong.
- Attacker spams contract, causing some array to become large. Then `for` loops iterating through the array might run out of gas and revert. See [this example](list_dos.sol#L26) that pauses & results list processing to prevent getting stuck due to out-of-gas errors.

## Mitigations

- Favor the pull-pattern: make funds available for users to withdraw rather than trying to send funds to users.
- If iterating over a dynamically sized data structure, be able to handle the case where the function takes multiple blocks to execute. One strategy for this is storing an iterator in a private variable and using `while` loop that stops when gas drops below certain threshold.

## References

- [Reddit conversation about stuck contract](https://www.reddit.com/r/ethereum/comments/4ghzhv/governmentals_1100_eth_jackpot_payout_is_stuck/)
- [ConsenSys re unexpected reverts](https://github.com/ConsenSys/smart-contract-best-practices#dos-with-unexpected-revert)
- [Griefing wallets](https://vessenes.com/ethereum-griefing-wallets-send-w-throw-considered-harmful/)
