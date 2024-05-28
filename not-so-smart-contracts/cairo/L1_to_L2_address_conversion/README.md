# L1 to L2 Address Conversion

In Starknet, addresses are of the `felt` type, while on L1 addresses are of the `uint160` type. To pass address types during cross-layer messaging, the address variable is typically given as a `uint256`. However, this may create an issue where an address on L1 maps to the zero address (or an unexpected address) on L2. This is because the primitive type in Cairo is the `felt`, which lies within the range `0 < x < P`, where P is the prime order of the curve. Usually, we have `P = 2^251 + 17 * 2^192 + 1`.

# Example

Consider the following code to initiate L2 deposits from L1. The first example has no checks on the `to` parameter, and depending on the user's address, it could transfer tokens to an unexpected address on L2. The second example, however, adds verification to ensure this does not happen. Note that the code is a simplified version of how messages are sent on L1 and processed on L2. For a more comprehensive overview, see here: [https://www.cairo-lang.org/docs/hello_starknet/l1l2.html](https://docs.cairo-lang.org/hello_starknet/l1l2.html).

```solidity
contract L1ToL2Bridge {
    uint256 public constant STARKNET_FIELD_PRIME; // the prime order P of the elliptic curve used
    IERC20 public constant token; // some token to deposit on L2

    event Deposited(uint256 to, uint256 amount);

    function badDepositToL2(uint256 to, uint256 amount) public returns (bool) {
        token.transferFrom(msg.sender, address(this), amount);
        emit Deposited(to, amount); // this message gets processed on L2
        return true;
    }

    function betterDepositToL2(uint256 to, uint256 amount) public returns (bool) {
        require(to != 0 && to < STARKNET_FIELD_PRIME, "invalid address"); // verifies 0 < to < P
        token.transferFrom(msg.sender, address(this), amount);
        emit Deposited(to, amount); // this message gets processed on L2
        return true;
    }
}
```

# Mitigations

When sending a message from L1 to L2, ensure verification of parameters, particularly user-supplied ones. Keep in mind that Cairo's default `felt` type range is smaller than the `uint256` type used by Solidity.
