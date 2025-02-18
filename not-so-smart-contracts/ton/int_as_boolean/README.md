# Using int as boolean values

In FunC, booleans are represented as integers; false is represented as 0 and true is represented as -1 (257 ones in binary notation).

Logical operations are done as bitwise operations over the binary representation of the integer values. Notably, The not operation `~` flips all the bits of an integer value; therefore, a non-zero value other than -1 becomes another non-zero value.

When a condition is checked, every non-zero integer is considered a true value. This, combined with the logical operations being bitwise operations, leads to an unexpected behavior of `if` conditions using the logical operations.

## Example

The following simplified code highlights the unexpected behavior of the `~` operator on a non-zero interger value.

```FunC
#include "imports/stdlib.fc";

() recv_internal(int my_balance, int msg_value, cell in_msg_full, slice in_msg_body) impure {
    int correct_true = -1;
    if (correct_true) {
        ~strdump("correct_true is true"); ;; printed
    } else {
        ~strdump("correct_true is false");
    }

    if (~ correct_true) {
        ~strdump("~correct_true is true");
    } else {
        ~strdump("~correct_true is false"); ;; printed
    }

    int correct_false = 0;
    if (correct_false) {
        ~strdump("correct_false is true");
    } else {
        ~strdump("correct_false is false"); ;; printed
    }

    if (~ correct_false) {
        ~strdump("~correct_false is true"); ;; printed
    } else {
        ~strdump("~correct_false is false");
    }

    int positive = 10;
    if (positive) {
        ~strdump("positive is true"); ;; printed
    } else {
        ~strdump("positive is false");
    }

    if (~ positive) {
        ~strdump("~positive is true"); ;; printed but unexpected
    } else {
        ~strdump("~positive is false");
    }

    int negative = -10;
    if (negative) {
        ~strdump("negative is true"); ;; printed
    } else {
        ~strdump("negative is false");
    }

    if (~ negative) {
        ~strdump("~negative is true"); ;; printed but unexpected
    } else {
        ~strdump("~negative is false");
    }
}
```

The `recv_internal` function above prints the following debug logs:

```
    #DEBUG#: correct_true is true
    #DEBUG#: ~correct_true is false
    #DEBUG#: correct_false is false
    #DEBUG#: ~correct_false is true
    #DEBUG#: positive is true
    #DEBUG#: ~positive is true
    #DEBUG#: negative is true
    #DEBUG#: ~negative is true
```

It demonstrats that the `~ 10` and `~ -10` both evaluate to `true` instead of becoming `false` with the `~` operator.

## Mitigations

- Always use `0` or `-1` in condition checks to get correct results.
- Be careful with the logical operator usage on non-zero integer values.
- Implement test cases to verify correct behavior of all condition checks with different integer values.
