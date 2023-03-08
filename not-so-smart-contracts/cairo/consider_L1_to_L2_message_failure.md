# Consider L1 to L2 message failure

In Starknet, [Ethereum contracts can send messages from L1 to L2, using a bridge](https://docs.starknet.io/documentation/architecture_and_concepts/L1-L2_Communication/messaging-mechanism/). However, it is not guaranteed that the message will be processed by the sequencer.
For instance, a message can fail to be processed if there is a sudden spike in the gas price and the value provided is too low. For that reason, Starknet developers provided a
[API to cancel on-going messages](https://docs.starknet.io/documentation/architecture_and_concepts/L1-L2_Communication/messaging-mechanism/#l2-l1_message_cancellation)

# Example

Suppose that the following code to initiate L2 deposits from L1, taking the tokens from the user:

```solidity
IERC20 public constant token; //some token to deposit on L2

function depositToL2(uint256 to,  uint256 amount) public returns (bool) {
    require(token.transferFrom(to, address(this), amount));
    ..
    StarknetCore.sendMessageToL2(..);
    return true;
}
```

If a L1 message is never processed by the sequencer, users will never receive their tokens either in L1 or L2, so they need a way to cancel it.

As a more real example, a recent [AAVE audit](https://github.com/aave-starknet-project/aave-starknet-bridge/pull/106#issue-1336925381) highlighed this issue and required to add code to cancel messages.

# Mitigations

When sending a message from L1 to L2, consider the case where a message is never processed by the sequencer. This can block either the contract to reach certain state or users to retrieve their funds. Allow to use `startL1ToL2MessageCancellation` and `cancelL1ToL2Message` to cancel ongoing messages, if needed.
