# Arithmetic overflow

The default primitive type, the felt or field element, behaves a lot like an integer does in any other language but it has a few important differences to keep in mind. The range of valid felt values is (-P/2,P/2). P here is the prime used by Cairo, which is current a 252-bit number. Arithemtic using felts is unchecked for overflow and can lead to unexpected results if this isn't properly accounted for. And since the range of values spans both negative and positive values, things like multiplying two positive numbers can have a negative value as a result, and vice versa, multiplying a two negative numbers doesn't always have a positive result.

StarkNet also provides the Uint256 module which offers a more typical 256-bit integer to developers. However, the arithmetic provided by this module is also unchecked so overflow is still something to keep in mind. For more robust integer support, consider using SafeMath from OpenZeppelin's Contracts for Cairo.

## Attack Scenarios



## Mitigations

- Always add checks for overflow when working with felts or Uint256s directly.
- Consider using the [OpenZeppelin Contracts for Cairo's SafeMath functions](https://github.com/OpenZeppelin/cairo-contracts/blob/main/src/openzeppelin/security/safemath.cairo) instead of doing arithmetic directly

## Examples
