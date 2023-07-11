# Arithmetic Overflow

The default primitive type, the field element (felt), behaves much like an integer in other languages, but there are a few important differences to keep in mind. A felt can be interpreted as a signed integer in the range (-P/2, P/2) or as an unsigned integer in the range (0, P]. P represents the prime used by Cairo, which is currently a 252-bit number. Arithmetic operations using felts are unchecked for overflow, which can lead to unexpected results if not properly accounted for. Since the range of values includes both negative and positive values, multiplying two positive numbers can result in a negative value and vice versa—multiplying two negative numbers does not always produce a positive result.

StarkNet also provides the Uint256 module, offering developers a more typical 256-bit integer. However, the arithmetic provided by this module is also unchecked, so overflow is still a concern. For more robust integer support, consider using SafeUint256 from OpenZeppelin's Contracts for Cairo.

## Attack Scenarios

## Mitigations

- Always add checks for overflow when working with felts or Uint256s directly.
- Consider using the [OpenZeppelin Contracts for Cairo's SafeUint256 functions](https://github.com/OpenZeppelin/cairo-contracts/blob/main/src/openzeppelin/security/safemath/library.cairo) instead of performing arithmetic directly.

## Examples
