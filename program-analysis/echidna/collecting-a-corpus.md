# Collecting, visualizing and modifying an Echidna corpus

**Table of contents:**

- [Introduction](#introduction)
- [Collecting a corpus](#collecting-a-corpus)
- [Seeding a corpus](#seeding-a-corpus)

## Introduction

We will see how to collect and use a corpus of transactions with Echidna. The target is the following smart contract (*[example/magic.sol](./example/magic.sol)*):

```Solidity
contract C {
  bool value_found = false;
  function magic(uint magic_1, uint magic_2, uint magic_3, uint magic_4) public {
    require(magic_1 == 42);
    require(magic_2 == 129);
    require(magic_3 == magic_4+333);
    value_found = true;
    return;
  }

  function echidna_magic_values() public returns (bool) {
    return !value_found;
  }

}
```

This small example forces Echidna to find certain values to change a state variable. This is hard for a fuzzer
(it is recommended to use a symbolic execution tool like [Manticore](https://github.com/trailofbits/manticore)).
We can run Echidna to verify this:

```
$ echidna-test magic.sol 
...

echidna_magic_values: passed! 🎉

Seed: 2221503356319272685
```

However, we can still use Echidna to collect corpus when running this fuzzing campaign.

## Collecting a corpus

To enable the corpus collection, create a corpus directory:

```
$ mkdir corpus-magic
```

And an [Echidna configuration file](https://github.com/crytic/echidna/wiki/Config) `config.yaml`:

```yaml
corpusDir: "corpus-magic"
```

Now we can run our tool and check the collected corpus:

```
$ echidna-test magic.sol --config config.yaml 
```

Echidna still cannot find the correct magic value. We can verify where it gets stuck reviewing the `corpus-magic/covered.*.txt` file:

```
r   |contract C {
  bool value_found = false;
r   |  function magic(uint magic_1, uint magic_2, uint magic_3, uint magic_4) public {
r   |    require(magic_1 == 42);
r   |    require(magic_2 == 129);
r   |    require(magic_3 == magic_4+333);
    value_found = true;
    return;
  }

  function echidna_magic_values() public returns (bool) {
    return !value_found;
  }

}
```

The label `r` on the left of each line shows that Echidna is able to reach these lines but it ends in a revert. 
As you can see, the fuzzer gets stuck in the last `require`.

To find a workaround, let's take look to the corpus it collected. For instance, one of these files was:

```json
[
   {
      "_gas'" : "0xffffffff",
      "_delay" : [
         "0x13647",
         "0xccf6"
      ],
      "_src" : "00a329c0648769a73afac7f9381e08fb43dbea70",
      "_dst" : "00a329c0648769a73afac7f9381e08fb43dbea72",
      "_value" : "0x0",
      "_call" : {
         "tag" : "SolCall",
         "contents" : [
            "magic",
            [
               {
                  "contents" : [
                     256,
                     "93723985220345906694500679277863898678726808528711107336895287282192244575836"
                  ],
                  "tag" : "AbiUInt"
               },
               {
                  "contents" : [
                     256,
                     "334"
                  ],
                  "tag" : "AbiUInt"
               },
               {
                  "contents" : [
                     256,
                     "68093943901352437066264791224433559271778087297543421781073458233697135179558"
                  ],
                  "tag" : "AbiUInt"
               },
               {
                  "tag" : "AbiUInt",
                  "contents" : [
                     256,
                     "332"
                  ]
               }
            ]
         ]
      },
      "_gasprice'" : "0xa904461f1"
   }
]
```

Clearly, this input will not trigger the failure in our property. However, in the next step, we will see how to modify it for that.

## Seeding a corpus

Echidna needs some help in order to deal with the `magic` function. We are going to copy and modify the input to use suitable
parameters for it:

```
$ cp corpus-magic/coverage/2712688662897926208.txt corpus-magic/coverage/new.txt
```

We will modify `new.txt` to call `magic(42,129,333,0)`. Now, we can re-run Echidna:

```
$ echidna-test magic.sol --config config.yaml 
...
echidna_magic_values: failed!💥  
  Call sequence:
    magic(42,129,333,0)


Unique instructions: 142
Unique codehashes: 1
Seed: -7293830866560616537

```

This time, the property is violated inmmediately. We can verify that another `covered.*.txt` file is created showing another trace (labeled with `*`) that Echidna executed that finished with a return at the end of the `magic` function.

```
*r  |contract C {
  bool value_found = false;
*r  |  function magic(uint magic_1, uint magic_2, uint magic_3, uint magic_4) public {
*r  |    require(magic_1 == 42);
*r  |    require(magic_2 == 129);
*r  |    require(magic_3 == magic_4+333);
*   |    value_found = true;
    return;
  }

  function echidna_magic_values() public returns (bool) {
    return !value_found;
  }

}
```
