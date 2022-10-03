# Denial of Service

A malicious contract can permanently stall another contract by failing
in a strategic way. In particular, contracts that bulk perform transactions or updates using
a `for` loop can be DoS'd if a call to another contract or `transfer` fails during the loop. 

## Attack Scenarios

- Auction contract where frontrunner must be reimbursed when they are outbid. If the call refunding
the frontrunner continuously fails, the auction is stalled and they become the de facto winner.

- Contract iterates through an array to pay back its users. If one `transfer` fails in the middle of a `for` loop
all reimbursements fail.

- Attacker spams contract, causing some array to become large. Then `for` loops iterating through the array 
might run out of gas and revert.

## Examples

- Both [insecure](auction.sol#L4) and [secure](auction.sol#L26) versions of the auction contract mentioned above

- Bulk refund functionality that is [suceptible to DoS](list_dos.sol#L3), and a [secure](list_dos.sol#L29) version

## Mitigations

- Favor pull over push for external calls
- If iterating over a dynamically sized data structure, be able to handle the case where the function
takes multiple blocks to execute. One strategy for this is storing iterator in a private variable and
using `while` loop that exists when gas drops below certain threshold.

## References

- https://www.reddit.com/r/ethereum/comments/4ghzhv/governmentals_1100_eth_jackpot_payout_is_stuck/
- https://github.com/ConsenSys/smart-contract-best-practices#dos-with-unexpected-revert
- https://vessenes.com/ethereum-griefing-wallets-send-w-throw-considered-harmful/
