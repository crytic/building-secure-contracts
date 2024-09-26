# Unchecked from address in L1 Handler function

A function with the `l1_handler` annotation is intended to be called from L1. The first parameter of the `l1_handler` function is always `from`, which represents the `msg.sender` of the L1 transaction that attempted to invoke the function on Starknet. If the `l1_handler` function is designed to be invoked from a specific address on mainnet, not checking the from address may allow anyone to call the function, opening up access control vulnerabilities.

## Example

The following Starknet bridge contract's owner, specified in the `uint256[] calldata payload` array, is designed to be called only from the `setOwnerOnL2()` function. Even though the owner is checked on the solidity side, the lack of validation of the `from_address` parameter allows anyone to call the function from an arbitrary L1 contract, becoming the owner of the bridge on L2.

```solidity
address public immutable OWNER;
address public immutable MESSENGER_CONTRACT;
address public immutable L2_BRIDGE_ADDRESS;
constructor(address _owner, address _messenger, address _bridge) {
    OWNER = _owner;
    MESSENGER_CONTRACT = _messenger;
    L2_BRIDGE_ADDRESS = _bridge;

}

function setOwnerOnL2(uint256[] calldata payload, uint256 selector) external {
    require(owner == msg.sender, "not owner");
    IStarknetMessaging(MESSENGER_CONTRACT).sendMessageToL2(L2_BRIDGE_ADDRESS, selector, payload);
}
```

```Cairo
#[storage]
struct Storage {
    owner: ContractAddress
}

#[l1_handler]
fn set_owner_from_l1(ref self: ContractState, from_address: felt252, new_owner: ContractAddress) {
    self.owner.write(new_owner);
}

```

## Mitigations

- Make sure to validate the `from_address`, otherwise any L1 contract can invoke the annotated Starknet function.
- Consider using Caracal, as it comes with a detector for verifying if the `from_address` is unchecked in an `l1_handler` function.
