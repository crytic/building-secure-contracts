# Denial of Service

A malicious contract can permanently stall another contract by failing
in a strategic way. In particular, contracts that bulk perform transactions or updates using
a `for` loop can be DoS'd if a call to another contract or `send` fails during the loop. 

## Attack Scenarios

- Auction contract where frontrunner must be reimbursed when they are outbid. If the call refunding
the frontrunner continuously fails, the auction is stalled and they become the de-facto winner.

- Contract iterates through an array to pay back its users. If one send fails in the middle of a `for` loop
all reimbursements fail.

- Attacker forces calling contract to spend remainder of its gas and revert.

## Examples

- Both [insecure](denial_of_service/auction.sol#L4) and [secure](denial_of_service/auction.sol#L26) versions of the auction contract mentioned above

- Bulk refund functionality that is [suceptible to DoS](denial_of_service/list_dos.sol#L3), and a [secure](denial_of_service/list_dos.sol#L29) version

## Mitigations

- Favor pull over push for external calls
- If iterating over a dynamically sized data structure, be able to handle the case where the function
takes multiple blocks to execute. One strategy for this is storing iterator in a private variable and
using `while` loop that exists when gas drops below certain threshold.