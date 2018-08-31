# Denial of Service

## Principle

A malicious contract can permanently stop another contract from behaving normally by failing
in a strategic way.

## Examples

- Auction contract where frontrunner must be reimbursed when they are outbid. If the call refunding
the frontrunner continuously fails, the auction is stalled and they become the de-facto winner.

- Contract iterates through an array to pay back its users. If one send fails in the middle of a `for` loop
all reimbursements fail.

- Attacker forces calling contract to spend remainder of its gas and revert.

## Best Practices

- Favor pull over push for external calls
- If iterating over a dynamically sized data structure, be able to handle the case where the function
takes multiple blocks to execute. One strategy for this is storing iterator in a private variable and
using `while` loop that exists when gas drops below certain threshold.