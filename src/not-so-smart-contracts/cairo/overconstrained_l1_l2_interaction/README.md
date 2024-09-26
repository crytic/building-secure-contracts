# Overconstrained L1 <-> L2 interaction

When interacting with contracts that are designed to interact with both L1 and L2, care must be taken that the checks and validations on both sides are symmetrical. If one side has more validations than the other, this could create a situation where a user performs an action on one side, but is unable to perform the corresponding action on the other side, leading to a loss of funds or a denial of service.

## Example

The following Starknet bridge contract allows for permissionless deposit to any address on L1 via the `deposit_to_L1` function. In particular, someone can deposit tokens to the `BAD_ADDRESS`. However, in that case the tokens will be lost forever, because the tokens are burned on L2 and the L1 contract's `depositFromL2` function prevents `BAD_ADDRESS` from being the recipient.

```Cairo
#[storage]
struct Storage {
    l1_bridge: EthAddress,
    balances: LegacyMap<ContractAddress,u256>
}

#[derive(Serde)]
struct Deposit {
    recipient: EthAddress,
    token: EthAddress,
    amount: u256
}

fn deposit_to_l1(ref self: ContractState, deposit: Deposit) {
    let caller = get_caller_address();
    //burn the tokens on the L2 side
    self.balances.write(caller, self.balances.read(caller) - deposit.amount);
    let payload = ArrayTrait::new();
    starknet::send_message_to_l1_syscall(self.l1_bridge.read(), deposit.serialize(ref payload)).unwrap();
}
```

```solidity

address public immutable MESSENGER_CONTRACT;
address public immutable L2_TOKEN_BRIDGE;
address public constant BAD_ADDRESS = address(0xdead);

constructor(address _messenger, address _bridge) {
    MESSENGER_CONTRACT = _messenger;
    L2_TOKEN_BRIDGE = _bridge;
}

function depositFromL2(address recipient, address token, uint256 amount) external {
    require(recipient != BAD_ADDRESS, "blacklisted");
    uint256[] memory payload = _buildPayload(recipient,token,amount);
    MESSENGER_CONTRACT.consumeMessageFromL2(L2_TOKEN_BRIDGE,payload);
    //deposit logic
    [...]
}

function _buildPayload(address recipient, address token, uint256 amount) internal returns (uint256[] memory) {
    //payload building logic for Starknet message
    [...]
}
```

## Mitigations

- Make sure to validate that the checks on both the L1 and L2 side are similar enough to prevent unexpected behavior. Ensure that any unsymmetric validations on either side cannot lead to a tokens being trapped or any other denial of service.
