# Overconstrained L1 <-> L2 interaction
When interacting with contracts that are designed to interact with both L1 and L2, care must be taken that the checks and validations on both sides are symmetrical. If one side has more validations than the other, this could create a situation where a user performs an action on one side, but is unable to perform the corresponding action on the other side, leading to a loss of funds or a denial of service.


## Example

The following Starknet bridge contract allows for permissionless deposit to any address from L1 via the `deposit_to_L2`. In particular, someone can deposit tokens to the `bad_address`.However the tokens will be trapped on L2 because the L2 contract's `deposit_from_L1` function is not permissionless and prevents `bad_address` from being the recipient.

```solidity
uint256 public immutable DEPOSIT_SELECTOR;
address public immutable MESSENGER_CONTRACT;
address public immutable L2_BRIDGE_ADDRESS;

constructor(uint256 _selector, address _messenger, address _bridge) {
    DEPOSIT_SELECTOR = _selector;
    MESSENGER_CONTRACT = _messenger;
    L2_BRIDGE_ADDRESS = _bridge;

}

function depositToL2(uint256[] calldata payload) external {
    require(owner == msg.sender, "not owner");
    IStarknetMessaging(MESSENGER_CONTRACT).sendMessageToL2(L2_BRIDGE_ADDRESS, DEPOSIT_SELECTOR, payload);
}
```

```Cairo
#[storage]
struct Storage {
    owner: ContractAddress,
    l1_bridge: EthAddress,
    bad_address: ContractAddress

}

#[l1_handler]
fn deposit_from_l1(ref self:ContractState, from_address: felt252, recipient: ContractAddress, amount) {
    assert(from_address == l1_bridge, "not bridge");
    assert(recipient != bad_address, "not allowed to deposit");
    //deposit logic
    [...]
}

```
## Mitigations

- Make sure to validate that the checks on both the L1 and L2 side are similar enough to prevent unexpected behavior. Ensure that any unsymmetric validations on either side cannot lead to a tokens being trapped or any other denial of service.