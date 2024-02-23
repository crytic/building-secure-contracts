# Arithmetic Overflow with Felt Type

The default primitive type, the field element (felt), behaves much like an integer in other languages, but there are a few important differences to keep in mind. A felt can be interpreted as an unsigned integer in the range [0, P], where P, a 252 bit prime, represents the order of the field used by Cairo. Arithmetic operations using felts are unchecked for overflow or underflow, which can lead to unexpected results if not properly accounted for. Do note that Cairo's builtin primitives for unsigned integers are overflow/underflow safe and will revert.

## Example

The following simplified code highlights the risk of felt underflow. The `check_balance` function is used to validate if a user has a large enough balance. However, the check is faulty because passing an amount such that `amt > balance` will underflow and the check will be true.

```Cairo

struct Storage {
    balances: LegacyMap<ContractAddress, felt252>
}

fn check_balance(self: @ContractState, amt: felt252) {
    let caller = get_caller_address();
    let balance = self.balances.read(caller);
    assert(balance - amt >= 0);
}

```

## Mitigations

- Always add checks for overflow when working with felts directly.
- Use the default signed integer types unless a felt is explicitly required.
- Consider using Caracal, as it comes with a detector for checking potential overflows when doing felt252 arithmetic operaitons.
