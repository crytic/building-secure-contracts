# L1 to L2 Message Failure

In Starknet, Ethereum contracts can send messages from L1 to L2 using a bridge. However, it is not guaranteed that the message will be processed by the sequencer. For instance, a message can fail to be processed if there is a sudden spike in the gas price and the value provided is too low. To address this issue, Starknet developers have provided an API to cancel ongoing messages.

# Example

Consider the following code to initiate L2 deposits from L1, taking the tokens from the user:

```solidity
contract L1ToL2Bridge {
    IERC20 public token; // some token to deposit on L2

    function depositToL2(address to, uint256 amount) public returns (bool) {
        require(token.transferFrom(msg.sender, address(this), amount));
        // ...
        StarknetCore.sendMessageToL2(data);
        return true;
    }
}
```

If an L1 message is never processed by the sequencer, users will never receive their tokens in either L1 or L2, and they need a way to cancel the message.

A recent AAVE audit highlighted this issue and required the addition of code to cancel messages.

# Mitigations

When sending a message from L1 to L2, it is essential to consider the possibility that a message may never be processed by the sequencer. This can block either the contract from reaching a certain state or users from retrieving their funds. If needed, allow the use of `startL1ToL2MessageCancellation` and `cancelL1ToL2Message` to cancel ongoing messages.
