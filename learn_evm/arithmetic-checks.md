# A Guide on Performing Arithmetic Checks in the EVM

The EVM is a peculiar machine that many of us have come to love and hate for all its quirks.
One such quirk is the absence of native arithmetic checks, which are typically present in most architectures and virtual machines through the use of carry bits or an overflow flag.
The EVM treats all stack values as uint256 types.
Although opcodes for signed integers (such as `sdiv`, `smod`, `slt`, `sgt`, etc.) exist,
arithmetic checks must be implemented within the constraints of the EVM.

> Note: [EIP-1051](https://eips.ethereum.org/EIPS/eip-1051)'s goal is to introduce the opcodes `ovf` and `sovf`.
> These would provide built-in overflow flags. However, the EIP's current status is stagnant.

Since Solidity version 0.8.0 the compiler includes over and underflow protection in all arithmetic operations by default.
Before version 0.8.0, these checks had to be implemented manually - a commonly used library is called [SafeMath](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol), originally developed by OpenZeppelin.
Much like how SafeMath works, arithmetic checks are inserted by the compiler through additional operations.

> **Disclaimer:** Please note that this post is for educational purposes.
> It is not our intention to encourage micro optimizations in order to save gas,
> as this can potentially lead to the introduction of new bugs that are difficult to detect and may compromise the security and stability of the protocol.
> As a protocol developer, it is important to prioritize the safety and security of the protocol over [premature optimization](https://www.youtube.com/watch?v=tKbV6BpH-C8).
> In situations where the code for the protocol is still evolving, including redundant checks for critical operations may be a good practice.
> However, we do encourage experimentation with these operations for educational purposes.

## Arithmetic checks for uint256 addition

To investigate how the solc compiler implements arithmetic checks, we can compile the code with the `--asm` flag and inspect the resulting bytecode.
Alternatively, by using the `--ir` flag, we can examine the Yul code that is generated as an intermediate representation (IR).

> It's worth noting that Solidity aims to make the new Yul pipeline the standard.
> Certain operations (including arithmetic checks) are always included as Yul code, regardless of whether the code is compiled with the new pipeline using `--via-ir`.
> This provides an opportunity to examine the Yul code and gain a better understanding of how arithmetic checks are executed in Solidity.
> However, it's important to keep in mind that the final bytecode may differ slightly when compiler optimizations are turned on.

To illustrate how the compiler detects overflow in unsigned integer addition, consider the following example of Yul code that is produced by the compiler.

```solidity
function checked_add_t_uint256(x, y) -> sum {
    x := cleanup_t_uint256(x)
    y := cleanup_t_uint256(y)

    // overflow, if x > (maxValue - y)
    if gt(x, sub(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, y)) { panic_error_0x11() }

    sum := add(x, y)
}
```

To enhance readability, we can interpret the Yul code back into high-level Solidity code.

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

The check for overflow in unsigned integer addition involves calculating the largest value that one summand can be added to the other without resulting in an overflow.
Specifically, in this case, the maximum value that `a` can have is `type(uint256).max - b`.
If `a` exceeds this value, we can conclude that `a + b` will overflow.

An alternative (and slightly more efficient) approach to computing the maximum value of `a` is to invert the bits on `b`.

```solidity
/// @notice versions >=0.8.0 && <0.8.16 with compiler optimizations
function checkedAddUint2(uint256 a, uint256 b) public pure returns (uint256 c) {
    unchecked {
        c = a + b;

        if (a > ~b) arithmeticError();
    }
}
```

This is equivalent, because `type(uint256).max` is a 256-bit integer with all its bits set to `1`.
Subtracting `b` from `type(uint256).max` can be viewed as inverting each bit in `b`.
This can be demonstrated by the transformation `~b = ~(0 ^ b) = ~0 ^ b = MAX ^ b = MAX - b`.

> It's worth noting that `a - b = a ^ b` is **NOT** a general rule, except in special cases, such as when one of the values equals `MAX`.
> We also obtain the relation `~b + 1 = 0 - b = -b` if we add `1` mod `2**256` to both sides of the previous equation.

By computing the result of the addition first and then performing a check on the sum,
modern versions of Solidity can eliminate the need for performing extra arithmetic operations in the comparison.

```solidity
/// @notice versions >=0.8.16
function checkedAddUint(uint256 a, uint256 b) public pure returns (uint256 c) {
    unchecked {
        c = a + b;

        if (a > c) arithmeticError();
    }
}
```

Overflow is detected when the sum is smaller than one of its summands.
In other words, if `a > a + b`, then overflow has occurred.
A full proof of this requires verifying that overflow occurs if and only if `a > a + b`.
An important observation is that `a > a + b` (mod `2**256`) for `b > 0` is only possible when `b >= 2**256`, which exceeds the maximum possible value.

## Arithmetic checks for int256 addition

The Solidity compiler generates the following (equivalent) code for detecting overflow in signed integer addition:

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

Like before, we can compute the maximum and minimum value of a summand given that the other summand is either positive or negative.

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

It's important to note that when comparing signed values, we must use the opcodes `slt` (signed less than) and `sgt` (signed greater than) to avoid interpreting signed integers as unsigned integers.
Solidity will automatically insert the correct opcode based on the type of the value. This applies to other signed operations as well.

### Quick primer on a two's complement system

In a two's complement system, the range of possible integers is divided into two halves: the positive and negative domain.
The first bit of an integer represents the sign, with `0` indicating a positive number and `1` indicating a negative number.
For positive integers (those with a sign bit of `0`), their binary representation is the same as their unsigned bit representation.
However, the negative domain is shifted to lie "above" the positive domain.

```
| -------------------------------- uint256 -------------------------------- |
0 --------------------------------------------------------------------- uint256_max

| --------- positive int256 --------- | --------- negative int256 --------- |
0 ------------------------ int256_max | int256_min ------------------------ -1
```

```solidity
0x0000000000000000000000000000000000000000000000000000000000000000 // 0
0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff // int256_max
0x8000000000000000000000000000000000000000000000000000000000000000 // int256_min
0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff // -1
```

The maximum positive integer that can be represented in a two's complement system using int256 is
`0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff` which is equal to half of the maximum value that can be represented using uint256.
The most significant bit of this number is `0`, while all other bits are `1`.

On the other hand, all negative numbers start with a `1` as their first bit.
If we look at the underlying hex representation of these numbers, they are all greater than or equal to the smallest integer that can be represented using int256, which is `0x8000000000000000000000000000000000000000000000000000000000000000` (equal to `1` shifted 255 bits to the left).

To obtain the negative value of an integer in a two's complement system, we can flip all the underlying bits and add `1`: `-a = ~a + 1`.
An example illustrates this.

```solidity
0x0000000000000000000000000000000000000000000000000000000000000003 // 3
0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc // ~3
0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd // -3 = ~3 + 1
```

To verify that `-a + a = 0` holds for all integers, we can use the property of two's complement arithmetic that `-a = ~a + 1`.
By substituting this into the equation, we get `-a + a = (~a + 1) + a = MAX + 1 = 0`, where `MAX` is the maximum integer value.

There is a unique case that needs special attention in two's complement arithmetic.
The smallest possible integer `int256).min = 0x8000000000000000000000000000000000000000000000000000000000000000 = -57896044618658097711785492504343953926634992332820282019728792003956564819968`
does not have a positive inverse for addition, making it the only negative number with this property.

Interestingly, if we try to compute `-type(int256).min`, we get the same number, as `-type(int256).min = ~type(int256).min + 1 = type(int256).min`.
This means there are two fixed points for additive inverses: `-0 = 0` and `-type(int256).min = type(int256).min`.
It's important to note that Solidity's arithmetic checks will throw an error when evaluating `-type(int256).min` (outside of unchecked blocks).

Finally, looking at the underlying bit (or hex) representation highlights the importance of using the correct operators for signed integers, such as `slt` instead of `lt`, to avoid misinterpreting negative values as large numbers.

```solidity
  0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff // int256(-1) or type(uint256).max
< 0x0000000000000000000000000000000000000000000000000000000000000000 // 0
// When using `slt`, the comparison is interpreted as `-1 < 0 = true`.
= 0x0000000000000000000000000000000000000000000000000000000000000001
// When using `lt`, the comparison is interpreted as `type(uint256).max < 0 = false`.
= 0x0000000000000000000000000000000000000000000000000000000000000000
```

Newer versions of Solidity prevent integer overflow by using the computed result `c = a + b` to check for overflow/underflow.
However, unlike unsigned addition, signed addition requires two separate checks instead of one.

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

Nevertheless, using the boolean exclusive-or lets us combine these checks into one step.
Solidity doesn't have a built-in operation for boolean values, but we can still make use of it through inline-assembly. In doing so, we need to take care that both inputs are actually boolean (either 0 or 1), as the xor operation works bitwise and isn't restricted to boolean values.

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

A different approach to detecting overflow in addition is to observe that adding two integers with different signs will never overflow.
This reduces the check to the case when both summands have the same sign.
If the sign of the sum is different from one of the summands, the result has overflowed.

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

Rather than checking the sign bit explicitly, which can be achieved by shifting the value to the right by 255 bits and checking that it is non-zero,
we can use the `slt` operation to compare the value with `0`.

## Arithmetic checks for uint256 subtraction

The process of checking for underflow in subtraction is akin to that of addition.
If we subtract `a - b`, and `b` is greater than `a`, we have an underflow situation.

```solidity
function checkedSubUint(uint256 a, uint256 b) public pure returns (uint256 c) {
    unchecked {
        c = a - b;

        if (b > a) arithmeticError();
    }
}
```

We could, like before, perform the check on the result itself using `if (c > a) arithmeticError();`, because subtracting a positive value from `a` should yield a value less than or equal to `a`.
However, in this case, we don't save any operations.

Just as with addition, for signed integers, we can combine the checks for both scenarios into a single check using `xor`.

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

To detect overflow when multiplying two unsigned integers, we can again use the approach of computing the maximum possible value of a multiplicand and check that it isn't exceeded.

```solidity
/// @notice versions >=0.8.0 && <0.8.17
function checkedMulUint1(uint256 a, uint256 b) public pure returns (uint256 c) {
    unchecked {
        c = a * b;

        if (a != 0 && b > type(uint256).max / a) arithmeticError();
    }
}
```

> It's important to note that the Solidity compiler always includes a division by zero check for all division and modulo operations, regardless of the presence of an unchecked block.
> The EVM itself simply returns `0` when dividing by `0`, and this also applies to inline-assembly.
> If the order of the boolean expressions is evaluated in reverse order, it could cause an arithmetic check to incorrectly revert when `a = 0`.

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

In older versions, the Solidity compiler uses four separate checks to detect integer multiplication overflow.
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

Newer Solidity versions optimize the process by utilizing the computed product in the check.

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

However, when performing the same calculations on a 256-bit machine, we need to extend the sign of the int64 value over all unused bits,
otherwise the value won't be interpreted correctly.

```solidity
                                   extended sign ──┐┌── 64-bit information
  0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe // int64(-2)
+ 0x0000000000000000000000000000000000000000000000000000000000000003 // int64(3)
= 0x0000000000000000000000000000000000000000000000000000000000000001 // int64(1)
```

It's worth noting that not all operations require clean upper bits.
In fact, even if the upper bits are dirty, we can still get correct results for addition.
However, the sum will usually contain dirty upper bits that will need to be cleaned.
For example, when performing addition without knowing what the upper bits are set to, we get the following result.

```solidity
  0x????????????????????????????????????????????????fffffffffffffffe // int64(-2)
+ 0x????????????????????????????????????????????????0000000000000003 // int64(3)
= 0x????????????????????????????????????????????????0000000000000001 // int64(1)
```

It is crucial to be mindful of when to clean the bits before and after operations.
By default, Solidity takes care of cleaning the bits before operations on smaller types and lets the optimizer remove any redundant steps.
However, values accessed after operations included by the compiler are not guaranteed to be clean. In particular, this is the case for addition with small data types.
The bit cleaning steps will be removed by the optimizer (even without optimizations enabled) if a variable is only accessed in a subsequent assembly block.
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
This is because Solidity does not take into account the fact that the variable is used in an assembly block, so the optimizer removes the bit cleaning operation, even if the Yul code includes it after the addition.

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
The most direct method, as just shown, involves checking the lower and upper bounds of the value.

```solidity
/// @notice Check used in int64 addition for version >= 0.8.16.
function overflowInt64(int256 value) public pure returns (bool overflow) {
    overflow = value > type(int64).max || value < type(int64).min;
}
```

We can simplify the expression to a single comparison if we're able to shift the disjointed number domain back so that it's connected.
To accomplish this, we subtract the smallest negative int64 `type(int64).min` from a value (or add the underlying unsigned value).
A better way to understand this is by visualizing the signed integer number domain in relation to the unsigned domain (which is demonstrated here using int128).

```
| -------------------------------- uint256 -------------------------------- |
0 --------------------------------------------------------------------- uint256_max

| --------- positive int256 --------- | --------- negative int256 --------- |
0 ------------------------ int256_max | int256_min ------------------------ -1
```

The domain for uint128/int128 can be visualized as follows.

```
| ------------ uint128 -------------- |                                     |
0 ----------------------- uint128_max |                                     |

| -- pos int128 -- |                                     | -- neg int128 -- |
0 ----- int128_max |                                     | int128_min ----- -1
```

After subtracting `type(int128).min` we get the following, connected set of values.

```
| ------------ uint128 -------------- |                                     |
0 ----------------------- uint128_max |                                     |

| -- neg int128 -- | -- pos int128 -- |                                     |
int128_min ----- -1| 0 --- int128_max |                                     |
```

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

In Yul, the equivalent code would resemble the following.

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

Finally, a full example for detecting signed 64-bit integer overflow, implemented in Solidity can be seen below.

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

## Arithmetic checks for multiplication with sub-32-byte types

If the product `c = a * b` can be calculated in 256 bits without the possibility of overflowing, we can once again verify whether the result can fit into the anticipated data type.
This is also the way Solidity handles the check in newer versions.

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
Overflow occurs in 256 bits, which loses information, and it won't be logical to check if the result fits into 192 bits.
In this scenario, we can depend on the previous checks and, for example, attempt to reconstruct one of the multiplicands.

```solidity
function checkedMulInt192_1(int192 a, int192 b) public pure returns (int192 c) {
    unchecked {
        c = a * b;

        if (a != 0 && b != c / a) arithmeticError();
        if (a = -1 && b == type(int192).min) arithmeticError();
    }
}
```

Once more, we must consider the two special circumstances:

1. When one of the multiplicands is zero (`a == 0`), the other multiplicand cannot be retrieved. However, this case never results in overflow.
2. Even if the multiplication is correct in 256 bits, the calculation overflows when only examining the least-significant 192 bits if the first multiplicand is minus one (`a = -1`) and the other multiplicand is the minimum value.

An example might help explain the second case.

```solidity
  0xffffffffffffffff800000000000000000000000000000000000000000000000 // type(int192).min
* 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff // -1
= 0x0000000000000000800000000000000000000000000000000000000000000000 // type(int192).min (when seen as a int192)
```

A way to handle this is to always start by sign-extending or cleaning the result before attempting to reconstruct the other multiplicand.
This then removes the need for checking the special condition.

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
