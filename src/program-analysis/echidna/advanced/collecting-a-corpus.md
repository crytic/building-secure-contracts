# Collecting, Visualizing, and Modifying an Echidna Corpus

**Table of contents:**

- [Introduction](#introduction)
- [Collecting a corpus](#collecting-a-corpus)
- [Seeding a corpus](#seeding-a-corpus)

## Introduction

In this guide, we will explore how to collect and use a corpus of transactions with Echidna. Our target is the following smart contract, [magic.sol](https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/example/magic.sol):

```solidity
contract C {
    bool value_found = false;

    function magic(uint256 magic_1, uint256 magic_2, uint256 magic_3, uint256 magic_4) public {
        require(magic_1 == 42);
        require(magic_2 == 129);
        require(magic_3 == magic_4 + 333);
        value_found = true;
        return;
    }

    function echidna_magic_values() public view returns (bool) {
        return !value_found;
    }
}
```

This small example requires Echidna to find specific values to change a state variable. While this is challenging for a fuzzer (it is advised to use a symbolic execution tool like [Manticore](https://github.com/trailofbits/manticore)), we can still employ Echidna to collect corpus during this fuzzing campaign.

## Collecting a corpus

To enable corpus collection, first, create a corpus directory:

```
mkdir corpus-magic
```

Next, create an [Echidna configuration file](https://github.com/crytic/echidna/wiki/Config) called `config.yaml`:

```yaml
corpusDir: "corpus-magic"
```

Now, run the tool and inspect the collected corpus:

```
echidna magic.sol --config config.yaml
```

Echidna is still unable to find the correct magic value. To understand where it gets stuck, review the `corpus-magic/covered.*.txt` file:

```
  1 | *   | contract C {
  2 |     |     bool value_found = false;
  3 |     |
  4 | *   |     function magic(uint256 magic_1, uint256 magic_2, uint256 magic_3, uint256 magic_4) public {
  5 | *r  |         require(magic_1 == 42);
  6 | *r  |         require(magic_2 == 129);
  7 | *r  |         require(magic_3 == magic_4 + 333);
  8 |     |         value_found = true;
  9 |     |         return;
 10 |     |     }
 11 |     |
 12 |     |     function echidna_magic_values() public returns (bool) {
 13 |     |         return !value_found;
 14 |     |     }
 15 |     | }
```

The label `r` on the left of each line indicates that Echidna can reach these lines, but they result in a revert. As you can see, the fuzzer gets stuck at the last `require`.

To find a workaround, let's examine the collected corpus. For instance, one of these files contains:

```json
[
    {
        "_gas'": "0xffffffff",
        "_delay": ["0x13647", "0xccf6"],
        "_src": "00a329c0648769a73afac7f9381e08fb43dbea70",
        "_dst": "00a329c0648769a73afac7f9381e08fb43dbea72",
        "_value": "0x0",
        "_call": {
            "tag": "SolCall",
            "contents": [
                "magic",
                [
                    {
                        "contents": [
                            256,
                            "93723985220345906694500679277863898678726808528711107336895287282192244575836"
                        ],
                        "tag": "AbiUInt"
                    },
                    {
                        "contents": [256, "334"],
                        "tag": "AbiUInt"
                    },
                    {
                        "contents": [
                            256,
                            "68093943901352437066264791224433559271778087297543421781073458233697135179558"
                        ],
                        "tag": "AbiUInt"
                    },
                    {
                        "tag": "AbiUInt",
                        "contents": [256, "332"]
                    }
                ]
            ]
        },
        "_gasprice'": "0xa904461f1"
    }
]
```

This input will not trigger the failure in our property. In the next step, we will show how to modify it for that purpose.

## Seeding a corpus

To handle the `magic` function, Echidna needs some assistance. We will copy and modify the input to utilize appropriate parameters:

```
cp corpus-magic/coverage/2712688662897926208.txt corpus-magic/coverage/new.txt
```

Modify `new.txt` to call `magic(42,129,333,0)`. Now, re-run Echidna:

```
echidna magic.sol --config config.yaml
...
echidna_magic_values: failed!💥
  Call sequence:
    magic(42,129,333,0)

Unique instructions: 142
Unique codehashes: 1
Seed: -7293830866560616537

```

This time, the property fails immediately. We can verify that another `covered.*.txt` file is created, showing a different trace (labeled with `*`) that Echidna executed, which ended with a return at the end of the `magic` function.

```
  1 | *   | contract C {
  2 |     |     bool value_found = false;
  3 |     |
  4 | *   |     function magic(uint256 magic_1, uint256 magic_2, uint256 magic_3, uint256 magic_4) public {
  5 | *r  |         require(magic_1 == 42);
  6 | *r  |         require(magic_2 == 129);
  7 | *r  |         require(magic_3 == magic_4 + 333);
  8 | *   |         value_found = true;
  9 |     |         return;
 10 |     |     }
 11 |     |
 12 |     |     function echidna_magic_values() public returns (bool) {
 13 |     |         return !value_found;
 14 |     |     }
 15 |     | }
```
