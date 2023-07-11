# A Guide on Performing Arithmetic Checks in the EVM

The Ethereum Virtual Machine (EVM) distinguishes itself from other virtual machines and computer systems through several unique aspects.
One notable difference is its treatment of arithmetic checks.
While most architectures and virtual machines provide access to carry bits or an overflow flag,
these features are absent in the EVM.
Consequently, these safeguards must be incorporated within the machine's constraints.

Starting with Solidity version 0.8.0 the compiler automatically includes over and underflow protection in all arithmetic operations.
Prior to version 0.8.0, developers were required to implement these checks manually, often using a library known as [SafeMath](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.2/contracts/utils/math/SafeMath.sol), originally developed by OpenZeppelin.
The compiler incorporates arithmetic checks in a manner similar to SafeMath, through additional operations.

As the Solidity language has evolved, the compiler has generated increasingly optimized code for arithmetic checks. This trend is also observed in smart contract development in general, where highly optimized arithmetic code written in low-level assembly is becoming more common. However, there is still a lack of comprehensive resources explaining the nuances of how the EVM handles arithmetic for signed and unsigned integers of 256 bits and less.

This article serves as a guide for gaining a deeper understanding of arithmetic in the EVM by exploring various ways to perform arithmetic checks. We'll learn more about the two's complement system and some lesser-known opcodes. This article is designed for those curious about the EVM's inner workings and those interested in bit manipulations in general. A basic understanding of bitwise arithmetic and Solidity opcodes is assumed.

Additional references for complementary reading are:

- [evm.codes](https://evm.codes)
- [Understanding Two's Complement](https://www.geeksforgeeks.org/twos-complement/)

> **Disclaimer:** Please note that this article is for educational purposes.
> It is not our intention to encourage micro optimizations in order to save gas,
> as this can potentially introduce new, hard-to-detect bugs that may compromise the security and stability of a protocol.
> As a developer, prioritize the safety and security of the protocol over [premature optimizations](https://www.youtube.com/watch?v=tKbV6BpH-C8).
> Including redundant checks for critical operations may be a good practice when the protocol code is still evolving.
> However, we do encourage experimentation with these operations for educational purposes.

## Arithmetic checks for uint256 addition

To examine how the solc compiler implements arithmetic checks, we can compile the code with the `--asm` flag and inspect the resulting bytecode.
Alternatively, using the `--ir` flag allows us to examine the Yul code that is generated as an intermediate representation (IR).

> Note that Solidity aims to make the new Yul pipeline the standard.
> Certain operations (including arithmetic checks) are always included as Yul code, regardless of whether the code is compiled with the new pipeline using `--via-ir`.
> This provides an opportunity to examine the Yul code and gain a better understanding of how arithmetic checks are executed in Solidity.
> However, keep in mind that the final bytecode may differ slightly when compiler optimizations are turned on.

To illustrate how the compiler detects overflow in unsigned integer addition, consider the following example of Yul code produced by the compiler before version 0.8.16.

```solidity
function checked_add_t_uint256(x, y) -> sum {
    x := cleanup_t_uint256(x)
    y := cleanup_t_uint256(y)

    // overflow, if x > (maxValue - y)
    if gt(x, sub(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, y)) { panic_error_0x11() }

    sum := add(x, y)
}
```

To improve readability, we can translate the Yul code back into high-level Solidity code.

```solidity
/// @notice versions >=0.8.0 && <0.8.16
function checkedAddUint1(uint256 a, uint256 b) public pure returns (uint256 c) {
    unchecked {
        c = a + b;

        if (a > type(uint256).max - b) arithmeticError();
    }
}
```

> Solidity's arithmetic errors are encoded as `abi.encodeWithSignature("Panic(uint256)", 0x11)`.

The check for overflow in unsigned integer addition involves calculating the largest value that one summand can have when added to the other without causing an overflow.
Specifically, in this case, the maximum value `a` can have is `type(uint256).max - b`.
If `a` exceeds this value, we can conclude that `a + b` will overflow.

An alternative and slightly more efficient approach for computing the maximum value of `a` involves inverting the bits of `b`.

```solidity
/// @notice versions >=0.8.0 && <0.8.16 with compiler optimizations
function checkedAddUint2(uint256 a, uint256 b) public pure returns (uint256 c) {
    unchecked {
        c = a + b;

        if (a > ~b) arithmeticError();
    }
}
```

This is process is equivalent, because `type(uint256).max` is a 256-bit integer with all its bits set to `1`.
Subtracting `b` from `type(uint256).max` can be viewed as inverting each bit in `b`.
This transformation is demonstrated by `~b = ~(0 ^ b) = ~0 ^ b = MAX ^ b = MAX - b`.

> Note that `a - b = a ^ b` is **NOT** a general rule, except in special cases, such as when one of the values equals `type(uint256).max`.
> The relation `~b + 1 = 0 - b = -b` is also obtained if we add `1` mod `2**256` to both sides of the previous equation.

By first calculating the result of the addition and then performing a check on the sum, the need performing extra arithmetic operations are removed.
This is how the compiler implements arithmetic checks for unsigned integer addition in versions 0.8.16 and later.

```solidity
/// @notice versions >=0.8.16
function checkedAddUint(uint256 a, uint256 b) public pure returns (uint256 c) {
    unchecked {
        c = a + b;

        if (a > c) arithmeticError();
    }
}
```

Overflow is detected when the sum is smaller than one of its addends.
In other words, if `a > a + b`, then overflow has occurred.
To fully prove this, it is necessary to verify that overflow occurs if and only if `a > a + b`.
An important observation is that `a > a + b` (mod `2**256`) for `b > 0` is only possible when `b >= 2**256`, which exceeds the maximum possible value.

## Arithmetic checks for int256 addition

The Solidity compiler generates the following (equivalent) code for detecting overflow in signed integer addition for versions below 0.8.16.

```solidity
/// @notice versions >=0.8.0 && <0.8.16
function checkedAddInt(int256 a, int256 b) public pure returns (int256 c) {
    unchecked {
        c = a + b;

        // If `a > 0`, then `b` can't exceed `type(int256).max - a`.
        if (a > 0 && b > type(int256).max - a) arithmeticError();
        // If `a < 0`, then `b` can't be less than `type(int256).min - a`.
        if (a < 0 && b < type(int256).min - a) arithmeticError();
    }
}
```

Similar to the previous example, we can compute the maximum and minimum value of one addend, given that the other is either positive or negative.

For reference, this is the Yul code that is produced when compiling via IR.

```solidity
function checked_add_t_int256(x, y) -> sum {
    x := cleanup_t_int256(x)
    y := cleanup_t_int256(y)

    // overflow, if x >= 0 and y > (maxValue - x)
    if and(iszero(slt(x, 0)), sgt(y, sub(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, x))) { panic_error_0x11() }
    // underflow, if x < 0 and y < (minValue - x)
    if and(slt(x, 0), slt(y, sub(0x8000000000000000000000000000000000000000000000000000000000000000, x))) { panic_error_0x11() }

    sum := add(x, y)
}
```

It's important to note that when comparing signed values, the opcodes `slt` (signed less than) and `sgt` (signed greater than) must be used to avoid interpreting signed integers as unsigned integers.
Solidity will automatically insert the correct opcode based on the value's type. This applies to other signed operations as well.

### Quick primer on a two's complement system

In a two's complement system, the range of possible integers is divided into two halves: the positive and negative domains.
The first bit of an integer represents the sign, with `0` indicating a positive number and `1` indicating a negative number.
For positive integers (those with a sign bit of `0`), their binary representation is the same as their unsigned bit representation.
However, the negative domain is shifted to lie "above" the positive domain.

$$\text{uint256 domain}$$

$$
├\underset{\hskip -0.5em 0}{─}────────────────────────────\underset{\hskip -3em 2^{256} - 1}{─}┤
$$

```solidity
0x0000000000000000000000000000000000000000000000000000000000000000 // 0
0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff // uint256_max
```

$$\text{int256 domain}$$

$$
\overset{positive}{
    ├\underset{\hskip -0.5em 0}{─}────────────\underset{\hskip -3em 2^{255} - 1}{─}┤
}
\overset{negative}{
    ├──\underset{\hskip -2.1em - 2^{255}}{─}──────────\underset{\hskip -1 em -1}{─}┤
}
$$

```solidity
0x0000000000000000000000000000000000000000000000000000000000000000 // 0
0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff // int256_max
0x8000000000000000000000000000000000000000000000000000000000000000 // int256_min
0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff // -1
```

The maximum positive integer that can be represented in a two's complement system using 256 bits is
`0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff` which is roughly equal to half of the maximum value that can be represented using `uint256`.
The most significant bit of this number is `0`, while all other bits are `1`.

On the other hand, all negative numbers start with a `1` as their first bit.
If we look at the underlying hex representation of these numbers, they are all greater than or equal to the smallest integer that can be represented using `int256`, which is `0x8000000000000000000000000000000000000000000000000000000000000000`. The integer's binary representation is a `1` followed by 255 `0`'s.

To obtain the negative value of an integer in a two's complement system, we flip the underlying bits and add `1`: `-a = ~a + 1`.
An example illustrates this.

```solidity
0x0000000000000000000000000000000000000000000000000000000000000003 // 3
0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc // ~3
0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd // -3 = ~3 + 1
```

To verify that `-a + a = 0` holds for all integers, we can use the property of two's complement arithmetic that `-a = ~a + 1`.
By substituting this into the equation, we get `-a + a = (~a + 1) + a = MAX + 1 = 0`, where `MAX` is the maximum integer value.

In two's complement arithmetic, there is a unique case that warrants special attention. The smallest possible integer `int256).min = 0x8000000000000000000000000000000000000000000000000000000000000000 = -57896044618658097711785492504343953926634992332820282019728792003956564819968`
does not have a positive inverse, making it the only negative number with this property.

Interestingly, if we try to compute `-type(int256).min`, we obtain the same number, as `-type(int256).min = ~type(int256).min + 1 = type(int256).min`.
This means there are two fixed points for additive inverses: `-0 = 0` and `-type(int256).min = type(int256).min`.
It's important to note that Solidity's arithmetic checks will throw an error when evaluating `-type(int256).min` (outside of unchecked blocks).

Examining the underlying bit (or hex) representation emphasizes the importance of using the correct operators for signed integers, such as `slt` instead of `lt`, to prevent misinterpreting negative values as large numbers.

```solidity
  0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff // int256(-1) or type(uint256).max
< 0x0000000000000000000000000000000000000000000000000000000000000000 // 0
// When using `slt`, the comparison is interpreted as `-1 < 0 = true`.
= 0x0000000000000000000000000000000000000000000000000000000000000001
// When using `lt`, the comparison is interpreted as `type(uint256).max < 0 = false`.
= 0x0000000000000000000000000000000000000000000000000000000000000000
```

Starting with Solidity versions 0.8.16, integer overflow is prevented by using the computed result `c = a + b` to check for overflow/underflow.
However, signed addition requires two separate checks instead of one, unlike unsigned addition.

```solidity
/// @notice versions >=0.8.16
function checkedAddInt2(int256 a, int256 b) public pure returns (int256 c) {
    unchecked {
        c = a + b;

        // If `a` is positive, then the sum `c = a + b` can't be less than `b`.
        if (a > 0 && c < b) arithmeticError();
        // If `a` is negative, then the sum `c = a + b` can't be greater than `b`.
        if (a < 0 && c > b) arithmeticError();
    }
}
```

Nevertheless, by utilizing the boolean exclusive-or, we can combine these checks into a single step.
Although Solidity does not allow the `xor` operation for boolean values, it can be used in inline-assembly.
While doing so, it is important to validate our assumptions that both inputs are genuinely boolean (either `0` or `1`), as the xor operation functions bitwise and is not limited to only boolean values.

```solidity
function checkedAddInt3(int256 a, int256 b) public pure returns (int256 c) {
    unchecked {
        c = a + b;

        bool overflow;

        assembly {
            // If `a >= 0`, then the sum `c = a + b` can't be less than `b`.
            // If `a <  0`, then the sum `c = a + b` can't be greater than `b`.
            // We combine these two conditions into one using `xor`.
            overflow := xor(slt(a, 0), sgt(b, c))
        }

        if (overflow) arithmeticError();
    }
}
```

An alternative approach to detecting overflow in addition is based on the observation that adding two integers with different signs will never result in an overflow.
This simplifies the check to the case when both operands have the same sign.
If the sign of the sum differs from one of the operands, the result has overflowed.

```solidity
function checkedAddInt4(int256 a, int256 b) public pure returns (int256 c) {
    unchecked {
        c = a + b;

        // Overflow, if the signs of `a` and `b` are the same,
        // but the sign of the result `c = a + b` differs from its summands.
        // When the signs of `a` and `b` differ overflow is not possible.
        if ((~a ^ b) & (a ^ c) < 0) arithmeticError();
    }
}
```

Instead of checking the sign bit explicitly, which can be done by shifting the value to the right by 255 bits and verifying that it is non-zero,
we can use the `slt` operation to compare the value with `0`.

## Arithmetic checks for uint256 subtraction

The process of checking for underflow in subtraction is similar to that of addition.
When subtracting `a - b`, and `b` is greater than `a`, an underflow occurs.

```solidity
function checkedSubUint(uint256 a, uint256 b) public pure returns (uint256 c) {
    unchecked {
        c = a - b;

        if (b > a) arithmeticError();
    }
}
```

Alternatively, we could perform the check on the result itself using `if (c > a) arithmeticError();`, because subtracting a positive value from `a` should yield a value less than or equal to `a`.
However, in this case, we don't save any operations.

Similar to addition, for signed integers, we can combine the checks for both scenarios into a single check using `xor`.

```solidity
function checkedSubInt(int256 a, int256 b) public pure returns (int256 c) {
    unchecked {
        c = a - b;

        bool overflow;

        assembly {
            // If `b >= 0`, then the result `c = a - b` can't be greater than `a`.
            // If `b <  0`, then the result `c = a - b` can't be less than `a`.
            overflow := xor(sgt(b, 0), sgt(a, c))
        }

        if (overflow) arithmeticError();
    }
}
```

## Arithmetic checks for uint256 multiplication

To detect overflow when multiplying two unsigned integers, we can use the approach of computing the maximum possible value of a multiplicand and check that it isn't exceeded.

```solidity
/// @notice versions >=0.8.0 && <0.8.17
function checkedMulUint1(uint256 a, uint256 b) public pure returns (uint256 c) {
    unchecked {
        c = a * b;

        if (a != 0 && b > type(uint256).max / a) arithmeticError();
    }
}
```

> The Solidity compiler always includes a zero check for all division and modulo operations, irrespective of whether an unchecked block is present.
> The EVM itself, however, returns `0` when dividing by `0`, which applies to inline-assembly as well.
> Evaluating the boolean expression `a != 0 && b > type(uint256).max / a` in reverse order would cause an incorrect reversion when `a = 0`.

We can compute the maximum value for `b` as long as `a` is non-zero. However, if `a` is zero, we know that the result will be zero as well, and there is no need to check for overflow.
Like before, we can also make use of the result and try to reconstruct one multiplicand from it. This is possible if the product didn't overflow and the first multiplicand is non-zero.

```solidity
/// @notice versions >=0.8.17
function checkedMulUint2(uint256 a, uint256 b) public pure returns (uint256 c) {
    unchecked {
        c = a * b;

        if (a != 0 && b != c / a) arithmeticError();
    }
}
```

For reference, we can further remove the additional division by zero check by writing the code in assembly.

```solidity
function checkedMulUint3(uint256 a, uint256 b) public pure returns (uint256 c) {
    unchecked {
        c = a * b;

        bool overflow;

        assembly {
            // This version does not include a redundant division-by-0 check
            // which the Solidity compiler includes when performing `c / a`.
            overflow := iszero(or(iszero(a), eq(div(c, a), b)))
        }

        if (overflow) arithmeticError();
    }
}
```

## Arithmetic checks for int256 multiplication

In versions before 0.8.17, the Solidity compiler uses four separate checks to detect integer multiplication overflow.
The produced Yul code is equivalent to the following high-level Solidity code.

```solidity
/// @notice versions >=0.8.0 && <0.8.17
function checkedMulInt(int256 a, int256 b) public pure returns (int256 c) {
    unchecked {
        c = a * b;

        if (a > 0 && b > 0 && a > type(int256).max / b) arithmeticError();
        if (a > 0 && b < 0 && a < type(int256).min / b) arithmeticError();
        if (a < 0 && b > 0 && a < type(int256).min / b) arithmeticError();
        if (a < 0 && b < 0 && a < type(int256).max / b) arithmeticError();
    }
}
```

Since Solidity version 0.8.17, the check is performed by utilizing the computed product in the check.

```solidity
/// @notice versions >=0.8.17
function checkedMulInt2(int256 a, int256 b) public pure returns (int256 c) {
    unchecked {
        c = a * b;

        if (a < 0 && b == type(int256).min) arithmeticError();
        if (a != 0 && b != c / a) arithmeticError();
    }
}
```

When it comes to integer multiplication, it's important to handle the case when `a < 0` and `b == type(int256).min`.
The actual case, where the product `c` will overflow, is limited to `a == -1` and `b == type(int256).min`.
This is because `-b` cannot be represented as a positive signed integer, as previously mentioned.

## Arithmetic checks for addition with sub-32-byte types

When performing arithmetic checks on data types that use less than 32 bytes, there are some additional steps to consider.
First, let's take a look at the addition of signed 64-bit integers.

On a 64-bit system, integer addition works in the same way as before.

```solidity
  0xfffffffffffffffe // int64(-2)
+ 0x0000000000000003 // int64(3)
= 0x0000000000000001 // int64(1)
```

However, when performing the same calculations on a 256-bit machine, we need to extend the sign of the `int64` value over all unused bits,
otherwise the value won't be interpreted correctly.

```solidity
                                   extended sign ──┐┌── 64-bit information
  0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe // int64(-2)
+ 0x0000000000000000000000000000000000000000000000000000000000000003 // int64(3)
= 0x0000000000000000000000000000000000000000000000000000000000000001 // int64(1)
```

It's worth noting that not all operations require clean upper bits. In fact, even if the upper bits are dirty, we can still get correct results for addition. However, the sum will usually contain dirty upper bits that will need to be cleaned. For example, we can perform addition without knowledge of the upper bits.

```solidity
  0x????????????????????????????????????????????????fffffffffffffffe // int64(-2)
+ 0x????????????????????????????????????????????????0000000000000003 // int64(3)
= 0x????????????????????????????????????????????????0000000000000001 // int64(1)
```

It is crucial to be mindful of when to clean the bits before and after operations.
By default, Solidity takes care of cleaning the bits before operations on smaller types and lets the optimizer remove any redundant steps.
However, values accessed after operations included by the compiler are not guaranteed to be clean. In particular, this is the case for addition with small data types.
For example, the bit cleaning steps will be removed by the optimizer (even without optimizations enabled) if a variable is only accessed in a subsequent assembly block.
Refer to the [Solidity documentation](https://docs.soliditylang.org/en/v0.8.18/internals/variable_cleanup.html#cleaning-up-variables) for further information on this matter.

When performing arithmetic checks in the same way as before, it is necessary to include a step to clean the bits on the sum.
One approach to achieve this is by performing `signextend(7, value)`, which extends the sign of a 64-bit (7 + 1 = 8 bytes) integer over all upper bits.

```solidity
function checkedAddInt64_1(int64 a, int64 b) public pure returns (int64 c) {
    unchecked {
        bool overflow;

        c = a + b;

        assembly {
            // Note that we must manually clean the upper bits in this case.
            // Solidity will optimize the cleaning away otherwise.
            // Extend the sign of the sum to 256 bits.
            c := signextend(7, c)

            // Perform the same arithmetic overflow check as before.
            overflow := xor(slt(a, 0), sgt(b, c))
        }

        if (overflow) arithmeticError();
    }
}
```

If we remove the line that includes `c := signextend(7, c)` the overflow check will not function correctly.
This is because Solidity does not take into account the fact that the variable is used in an assembly block, and the optimizer removes the bit cleaning operation, even if the Yul code includes it after the addition.

One thing to keep in mind is that since we are performing a 64-bit addition in 256 bits, we practically have access to the carry/overflow bits.
If our computed value does not overflow, then it will fall within the correct bounds `type(int64).min <= c <= type(int64).max`.
The actual overflow check in Solidity involves verifying both the upper and lower bounds.

```solidity
/// @notice version >= 0.8.16
function checkedAddInt64_2(int64 a, int64 b) public pure returns (int64 c) {
    unchecked {
        // Perform the addition in int256.
        int256 uc = int256(a) + b;

        // If the value can not be represented by a int64, there is overflow.
        if (uc > type(int64).max || uc < type(int64).min) arithmeticError();

        // We can safely cast the result.
        c = int64(uc);
    }
}
```

There are a few ways to verify that the result in its 256-bit representation will fit into the expected data type.
This is only true when all upper bits are the same.
The most direct method, as previously shown, involves verifying both the lower and upper bounds.

```solidity
/// @notice Check used in int64 addition for version >= 0.8.16.
function overflowInt64(int256 value) public pure returns (bool overflow) {
    overflow = value > type(int64).max || value < type(int64).min;
}
```

We can simplify the expression to a single comparison if we can shift the disjointed number domain back so that it's connected.
To accomplish this, we subtract the smallest negative `int64` (`type(int64).min`) from a value (or add the underlying unsigned value).
A better way to understand this is by visualizing the signed integer number domain in relation to the unsigned domain (which is demonstrated here using `int128`).

$$\text{uint256 domain}$$

$$
├\underset{\hskip -0.5em 0}{─}────────────────────────────\underset{\hskip -3em 2^{256} - 1}{─}┤
$$

$$\text{int256 domain}$$

$$
\overset{positive}{
    ├\underset{\hskip -0.5em 0}{─}────────────\underset{\hskip -3em 2^{255} - 1}{─}┤
}
\overset{negative}{
    ├──\underset{\hskip -2.1em - 2^{255}}{─}──────────\underset{\hskip -1 em -1}{─}┤
}
$$

The domain for `uint128`/`int128` can be visualized as follows.

$$\text{uint128 domain}$$

$$
├\underset{\hskip -0.5em 0}─────────────\underset{\hskip -3em 2^{128}-1}─┤
\hskip 7em┆
$$

$$\text{int128 domain}$$

$$
├\underset{\hskip -0.5em 0}{─}────\underset{\hskip -3em 2^{127} - 1}─\overset{\hskip -3em positive}{┤}
\hskip 7em
├──\underset{\hskip -2.1em - 2^{127}}───\underset{\hskip -1 em -1}{─}\overset{\hskip -3em negative}{┤}
$$

Note that the scales of the number ranges in the previous section do not accurately depict the magnitude of numbers that are representable with the different types and only serve as a visualization. We can represent twice as many numbers with only one additional bit, yet the uint256 domain has twice the number of bits compared to uint128.

After subtracting `type(int128).min` (or adding `2**127`) and essentially shifting the domains to the right, we get the following, connected set of values.

$$
├\underset{\hskip -0.5em 0}{─}────────────\underset{\hskip -3em 2^{128}-1}─┤
\hskip 7em┆
$$

$$
├──────\overset{\hskip -3em negative}{┤}
├──────\overset{\hskip -3em positive}{┤}
\hskip 7em┆
$$

If we interpret the shifted value as an unsigned integer, we only need to check whether it exceeds the maximum unsigned integer `type(uint128).max`.
The corresponding check in Solidity is shown below.

```solidity
function overflowInt64_2(int256 value) public pure returns (bool overflow) {
    unchecked {
        overflow = uint256(value) - uint256(int256(type(int64).min)) > type(uint64).max;
    }
}
```

In this case the verbose assembly code might actually be easier to follow than the Solidity code which sometimes contains implicit operations.

```solidity
int64 constant INT64_MIN = -0x8000000000000000;
uint64 constant UINT64_MAX = 0xffffffffffffffff;

function overflowInt64_2_yul(int256 value) public pure returns (bool overflow) {
    assembly {
        overflow := gt(sub(value, INT64_MIN), UINT64_MAX)
    }
}
```

As mentioned earlier, this approach is only effective for negative numbers when all of their upper bits are set to `1`, allowing us to overflow back into the positive domain.
An alternative and more straightforward method would be to simply verify that all of the upper bits are equivalent to the sign bit for all integers.

```solidity
function overflowInt64_3(int256 value) public pure returns (bool overflow) {
    overflow = value != int64(value);
}
```

In Yul, the equivalent resembles the following.

```solidity
function overflowInt64_3_yul(int256 value) public pure returns (bool overflow) {
    assembly {
        overflow := iszero(eq(value, signextend(7, value)))
    }
}
```

Another way of extending the sign is to make use of `sar` (signed arithmetic right shift).

```solidity
function overflowInt64_4(int256 value) public pure returns (bool overflow) {
    overflow = value != (value << 192) >> 192;
}

function overflowInt64_4_yul(int256 value) public pure returns (bool overflow) {
    assembly {
        overflow := iszero(eq(value, sar(192, shl(192, value))))
    }
}
```

Finally, a full example for detecting signed 64-bit integer overflow, implemented in Solidity can be seen below:

```solidity
function checkedAddInt64_2(int64 a, int64 b) public pure returns (int64 c) {
    unchecked {
        // Cast the first summand.
        // The second summand is implicitly casted.
        int256 uc = int256(a) + b;

        // Check whether the result `uc` can be represented by 64 bits
        // by shifting the values to the uint64 domain.
        // This is done by subtracting the smallest value in int64.
        if (uint256(uc) - uint256(int256(type(int64).min)) > type(uint64).max) arithmeticError();

        // We can safely cast the result.
        c = int64(uc);
    }
}
```

One further optimization that we could perform is to add `-type(int64).min` instead of subtracting `type(int64).min`. This would not reduce computation costs, however it could end up reducing bytecode size. This is because when we subtract `-type(int64).min`, we need to push 32 bytes (`0xffffffffffffffffffffffffffffffffffffffffffffffff8000000000000000`), whereas when we add `-type(int64).min`, we only end up pushing 8 bytes (`0x8000000000000000`). However, as soon as we turn on compiler optimizations, the produced bytecode ends up being the same.

## Arithmetic checks for multiplication with sub-32-byte types

When the product `c = a * b` can be calculated in 256 bits without the possibility of overflowing, we can verify whether the result can fit into the anticipated data type. This is also the way Solidity handles the check in versions 0.8.17 and later.

```solidity
/// @notice version >= 0.8.17
function checkedMulInt64(int64 a, int64 b) public pure returns (int64 c) {
    unchecked {
        int256 uc = int256(a) * int256(b);

        // If the product can not be represented with 64 bits,
        // there is overflow.
        if (overflowInt64(uc)) arithmeticError();

        c = int64(uc);
    }
}
```

However, if the maximum value of a product exceeds 256 bits, then this method won't be effective.
This happens, for instance, when working with int192. The product `type(int192).min * type(int192).min` requires 192 + 192 = 384 bits to be stored, which exceeds the maximum of 256 bits.
Overflow occurs in 256 bits, causing a loss of information, and it won't be logical to check if the result fits into 192 bits.
In this scenario, we can rely on the previous checks and, for example, attempt to reconstruct one of the multiplicands.

```solidity
function checkedMulInt192_1(int192 a, int192 b) public pure returns (int192 c) {
    unchecked {
        c = a * b;

        if (a != 0 && b != c / a) arithmeticError();
        if (a = -1 && b == type(int192).min) arithmeticError();
    }
}
```

We must consider the two special circumstances:

1. When one of the multiplicands is zero (`a == 0`), the other multiplicand cannot be retrieved. However, this case never results in overflow.
2. Even if the multiplication is correct in 256 bits, the calculation overflows when only examining the least-significant 192 bits if the first multiplicand is negative one (`a = -1`) and the other multiplicand is the minimum value.

An example might help explain the second case.

```solidity
  0xffffffffffffffff800000000000000000000000000000000000000000000000 // type(int192).min
* 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff // -1
= 0x0000000000000000800000000000000000000000000000000000000000000000 // type(int192).min (when looking at the first 192 bits)
```

A method to address this issue is to always start by sign-extending or cleaning the result before attempting to reconstruct the other multiplicand.
By doing so, it eliminates the need to check for the special condition.

```solidity
/// @notice version >= 0.8.17
function checkedMulInt192_2(int192 a, int192 b) public pure returns (int192 c) {
    unchecked {
        bool overflow;

        assembly {
            // Extend the sign for int192 (24 = 23 + 1 bytes).
            c := signextend(23, mul(a, b))

            // Overflow, if `a != 0 && b != c / a`.
            overflow := iszero(or(iszero(a), eq(b, sdiv(c, a))))
        }

        if (overflow) arithmeticError();
    }
}
```

## Conclusion

In conclusion, we hope this article has served as an informative guide on signed integer arithmetic within the EVM and the two's complement system.
We have explored:

- How the EVM makes use of the two's complement representation
- How integer values are interpreted as signed or unsigned depending on the opcodes used
- The added complexity from handling arithmetic for signed vs. unsigned integers
- The intricacies involved in managing sub 32-byte types
- The importance of bit-cleaning and the significance of `signextend`

While low-level optimizations are attractive, they are also heavily error-prone. This article aims to deepen one's understanding of low-level arithmetic, to reduce these risks. Nevertheless, it is crucial to integrate custom low-level optimizations only after thorough manual analysis, automated testing, and to document any non-obvious assumptions.
