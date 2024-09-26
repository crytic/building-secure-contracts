# Ethereum VM (EVM) Opcodes and Instruction Reference

This reference consolidates EVM opcode information from the [yellow paper](https://ethereum.github.io/yellowpaper/paper.pdf), [stack exchange](https://ethereum.stackexchange.com/questions/119/what-opcodes-are-available-for-the-ethereum-evm), [solidity source](https://github.com/ethereum/solidity/blob/c61610302aa2bfa029715b534719d25fe3949059/libevmasm/Instruction.h#L40), [parity source](https://github.com/paritytech/parity/blob/d365281cce919edc42340c97ce212f49d9447d2d/ethcore/evm/src/instructions.rs#L311), [evm-opcode-gas-costs](https://github.com/djrtwo/evm-opcode-gas-costs/blob/master/opcode-gas-costs_EIP-150_revision-1e18248_2017-04-12.csv) and [Manticore](https://github.com/trailofbits/manticore/blob/c6f457d72e1164c4c8c6d0256fe9b8b765d2cb24/manticore/platforms/evm.py#L590).

## Notes

The size of a "word" in EVM is 256 bits.

The gas information is a work in progress. If an asterisk is in the Gas column, the base cost is shown but may vary based on the opcode arguments.

## Table

| Opcode                    | Name           | Description                                                                                                                                                  | Extra Info                                                                                                | Gas         |
| ------------------------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------- | ----------- |
| [`0x00`](#stop)           | STOP           | Halts execution                                                                                                                                              | -                                                                                                         | 0           |
| [`0x01`](#add)            | ADD            | Addition operation                                                                                                                                           | -                                                                                                         | 3           |
| [`0x02`](#mul)            | MUL            | Multiplication operation                                                                                                                                     | -                                                                                                         | 5           |
| [`0x03`](#sub)            | SUB            | Subtraction operation                                                                                                                                        | -                                                                                                         | 3           |
| [`0x04`](#div)            | DIV            | Integer division operation                                                                                                                                   | -                                                                                                         | 5           |
| [`0x05`](#sdiv)           | SDIV           | Signed integer division operation (truncated)                                                                                                                | -                                                                                                         | 5           |
| [`0x06`](#mod)            | MOD            | Modulo remainder operation                                                                                                                                   | -                                                                                                         | 5           |
| [`0x07`](#smod)           | SMOD           | Signed modulo remainder operation                                                                                                                            | -                                                                                                         | 5           |
| [`0x08`](#addmod)         | ADDMOD         | Modulo addition operation                                                                                                                                    | -                                                                                                         | 8           |
| [`0x09`](#mulmod)         | MULMOD         | Modulo multiplication operation                                                                                                                              | -                                                                                                         | 8           |
| [`0x0a`](#exp)            | EXP            | Exponential operation                                                                                                                                        | -                                                                                                         | 10\*        |
| [`0x0b`](#signextend)     | SIGNEXTEND     | Extend length of two's complement signed integer                                                                                                             | -                                                                                                         | 5           |
| `0x0c` - `0x0f`           | Unused         | Unused                                                                                                                                                       | -                                                                                                         |
| [`0x10`](#lt)             | LT             | Less-than comparison                                                                                                                                         | -                                                                                                         | 3           |
| [`0x11`](#gt)             | GT             | Greater-than comparison                                                                                                                                      | -                                                                                                         | 3           |
| [`0x12`](#slt)            | SLT            | Signed less-than comparison                                                                                                                                  | -                                                                                                         | 3           |
| [`0x13`](#sgt)            | SGT            | Signed greater-than comparison                                                                                                                               | -                                                                                                         | 3           |
| [`0x14`](#eq)             | EQ             | Equality comparison                                                                                                                                          | -                                                                                                         | 3           |
| [`0x15`](#iszero)         | ISZERO         | Simple not operator                                                                                                                                          | -                                                                                                         | 3           |
| [`0x16`](#and)            | AND            | Bitwise AND operation                                                                                                                                        | -                                                                                                         | 3           |
| [`0x17`](#or)             | OR             | Bitwise OR operation                                                                                                                                         | -                                                                                                         | 3           |
| [`0x18`](#xor)            | XOR            | Bitwise XOR operation                                                                                                                                        | -                                                                                                         | 3           |
| [`0x19`](#not)            | NOT            | Bitwise NOT operation                                                                                                                                        | -                                                                                                         | 3           |
| [`0x1a`](#byte)           | BYTE           | Retrieve single byte from word                                                                                                                               | -                                                                                                         | 3           |
| [`0x1b`](#shl)            | SHL            | Shift Left                                                                                                                                                   | [EIP145](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-145.md)                                    | 3           |
| [`0x1c`](#shr)            | SHR            | Logical Shift Right                                                                                                                                          | [EIP145](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-145.md)                                    | 3           |
| [`0x1d`](#sar)            | SAR            | Arithmetic Shift Right                                                                                                                                       | [EIP145](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-145.md)                                    | 3           |
| [`0x20`](#keccak256)      | KECCAK256      | Compute Keccak-256 hash                                                                                                                                      | -                                                                                                         | 30\*        |
| `0x21` - `0x2f`           | Unused         | Unused                                                                                                                                                       |
| [`0x30`](#address)        | ADDRESS        | Get address of currently executing account                                                                                                                   | -                                                                                                         | 2           |
| [`0x31`](#balance)        | BALANCE        | Get balance of the given account                                                                                                                             | -                                                                                                         | 700         |
| [`0x32`](#origin)         | ORIGIN         | Get execution origination address                                                                                                                            | -                                                                                                         | 2           |
| [`0x33`](#caller)         | CALLER         | Get caller address                                                                                                                                           | -                                                                                                         | 2           |
| [`0x34`](#callvalue)      | CALLVALUE      | Get deposited value by the instruction/transaction responsible for this execution                                                                            | -                                                                                                         | 2           |
| [`0x35`](#calldataload)   | CALLDATALOAD   | Get input data of current environment                                                                                                                        | -                                                                                                         | 3           |
| [`0x36`](#calldatasize)   | CALLDATASIZE   | Get size of input data in current environment                                                                                                                | -                                                                                                         | 2\*         |
| [`0x37`](#calldatacopy)   | CALLDATACOPY   | Copy input data in current environment to memory                                                                                                             | -                                                                                                         | 3           |
| [`0x38`](#codesize)       | CODESIZE       | Get size of code running in current environment                                                                                                              | -                                                                                                         | 2           |
| [`0x39`](#codecopy)       | CODECOPY       | Copy code running in current environment to memory                                                                                                           | -                                                                                                         | 3\*         |
| [`0x3a`](#gasprice)       | GASPRICE       | Get price of gas in current environment                                                                                                                      | -                                                                                                         | 2           |
| [`0x3b`](#extcodesize)    | EXTCODESIZE    | Get size of an account's code                                                                                                                                | -                                                                                                         | 700         |
| [`0x3c`](#extcodecopy)    | EXTCODECOPY    | Copy an account's code to memory                                                                                                                             | -                                                                                                         | 700\*       |
| [`0x3d`](#returndatasize) | RETURNDATASIZE | Pushes the size of the return data buffer onto the stack                                                                                                     | [EIP 211](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-211.md)                                   | 2           |
| [`0x3e`](#returndatacopy) | RETURNDATACOPY | Copies data from the return data buffer to memory                                                                                                            | [EIP 211](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-211.md)                                   | 3           |
| [`0x3f`](#extcodehash)    | EXTCODEHASH    | Returns the keccak256 hash of a contract's code                                                                                                              | [EIP 1052](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1052.md)                                 | 700         |
| [`0x40`](#blockhash)      | BLOCKHASH      | Get the hash of one of the 256 most recent complete blocks                                                                                                   | -                                                                                                         | 20          |
| [`0x41`](#coinbase)       | COINBASE       | Get the block's beneficiary address                                                                                                                          | -                                                                                                         | 2           |
| [`0x42`](#timestamp)      | TIMESTAMP      | Get the block's timestamp                                                                                                                                    | -                                                                                                         | 2           |
| [`0x43`](#number)         | NUMBER         | Get the block's number                                                                                                                                       | -                                                                                                         | 2           |
| [`0x44`](#difficulty)     | DIFFICULTY     | Get the block's difficulty                                                                                                                                   | -                                                                                                         | 2           |
| [`0x45`](#gaslimit)       | GASLIMIT       | Get the block's gas limit                                                                                                                                    | -                                                                                                         | 2           |
| [`0x46`](#chainid)        | CHAINID        | Returns the current chain’s EIP-155 unique identifier                                                                                                        | [EIP 1344](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1344.md)                                 | 2           |
| `0x47` - `0x4f`           | Unused         | -                                                                                                                                                            |
| [`0x48`](#basefee)        | BASEFEE        | Returns the value of the base fee of the current block it is executing in.                                                                                   | [EIP 3198](https://eips.ethereum.org/EIPS/eip-3198)                                                       | 2           |
| [`0x50`](#pop)            | POP            | Remove word from stack                                                                                                                                       | -                                                                                                         | 2           |
| [`0x51`](#mload)          | MLOAD          | Load word from memory                                                                                                                                        | -                                                                                                         | 3\*         |
| [`0x52`](#mstore)         | MSTORE         | Save word to memory                                                                                                                                          | -                                                                                                         | 3\*         |
| [`0x53`](#mstore8)        | MSTORE8        | Save byte to memory                                                                                                                                          | -                                                                                                         | 3           |
| [`0x54`](#sload)          | SLOAD          | Load word from storage                                                                                                                                       | -                                                                                                         | 800         |
| [`0x55`](#sstore)         | SSTORE         | Save word to storage                                                                                                                                         | -                                                                                                         | 20000\*\*   |
| [`0x56`](#jump)           | JUMP           | Alter the program counter                                                                                                                                    | -                                                                                                         | 8           |
| [`0x57`](#jumpi)          | JUMPI          | Conditionally alter the program counter                                                                                                                      | -                                                                                                         | 10          |
| [`0x58`](#pc)             | PC             | Get the value of the program counter prior to the increment                                                                                                  | -                                                                                                         | 2           |
| [`0x59`](#msize)          | MSIZE          | Get the size of active memory in bytes                                                                                                                       | -                                                                                                         | 2           |
| [`0x5a`](#gas)            | GAS            | Get the amount of available gas, including the corresponding reduction for the cost of this instruction                                                      | -                                                                                                         | 2           |
| [`0x5b`](#jumpdest)       | JUMPDEST       | Mark a valid destination for jumps                                                                                                                           | -                                                                                                         | 1           |
| `0x5c` - `0x5e`           | Unused         | -                                                                                                                                                            |
| [`0x5f`](#push0)          | PUSH0          | Place the constant value 0 on stack                                                                                                                          | [EIP-3855](https://eips.ethereum.org/EIPS/eip-3855)                                                       | 2           |
| [`0x60`](#push1)          | PUSH1          | Place 1 byte item on stack                                                                                                                                   | -                                                                                                         | 3           |
| [`0x61`](#push2)          | PUSH2          | Place 2-byte item on stack                                                                                                                                   | -                                                                                                         | 3           |
| [`0x62`](#push3)          | PUSH3          | Place 3-byte item on stack                                                                                                                                   | -                                                                                                         | 3           |
| [`0x63`](#push4)          | PUSH4          | Place 4-byte item on stack                                                                                                                                   | -                                                                                                         | 3           |
| [`0x64`](#push5)          | PUSH5          | Place 5-byte item on stack                                                                                                                                   | -                                                                                                         | 3           |
| [`0x65`](#push6)          | PUSH6          | Place 6-byte item on stack                                                                                                                                   | -                                                                                                         | 3           |
| [`0x66`](#push7)          | PUSH7          | Place 7-byte item on stack                                                                                                                                   | -                                                                                                         | 3           |
| [`0x67`](#push8)          | PUSH8          | Place 8-byte item on stack                                                                                                                                   | -                                                                                                         | 3           |
| [`0x68`](#push9)          | PUSH9          | Place 9-byte item on stack                                                                                                                                   | -                                                                                                         | 3           |
| [`0x69`](#push10)         | PUSH10         | Place 10-byte item on stack                                                                                                                                  | -                                                                                                         | 3           |
| [`0x6a`](#push11)         | PUSH11         | Place 11-byte item on stack                                                                                                                                  | -                                                                                                         | 3           |
| [`0x6b`](#push12)         | PUSH12         | Place 12-byte item on stack                                                                                                                                  | -                                                                                                         | 3           |
| [`0x6c`](#push13)         | PUSH13         | Place 13-byte item on stack                                                                                                                                  | -                                                                                                         | 3           |
| [`0x6d`](#push14)         | PUSH14         | Place 14-byte item on stack                                                                                                                                  | -                                                                                                         | 3           |
| [`0x6e`](#push15)         | PUSH15         | Place 15-byte item on stack                                                                                                                                  | -                                                                                                         | 3           |
| [`0x6f`](#push16)         | PUSH16         | Place 16-byte item on stack                                                                                                                                  | -                                                                                                         | 3           |
| [`0x70`](#push17)         | PUSH17         | Place 17-byte item on stack                                                                                                                                  | -                                                                                                         | 3           |
| [`0x71`](#push18)         | PUSH18         | Place 18-byte item on stack                                                                                                                                  | -                                                                                                         | 3           |
| [`0x72`](#push19)         | PUSH19         | Place 19-byte item on stack                                                                                                                                  | -                                                                                                         | 3           |
| [`0x73`](#push20)         | PUSH20         | Place 20-byte item on stack                                                                                                                                  | -                                                                                                         | 3           |
| [`0x74`](#push21)         | PUSH21         | Place 21-byte item on stack                                                                                                                                  | -                                                                                                         | 3           |
| [`0x75`](#push22)         | PUSH22         | Place 22-byte item on stack                                                                                                                                  | -                                                                                                         | 3           |
| [`0x76`](#push23)         | PUSH23         | Place 23-byte item on stack                                                                                                                                  | -                                                                                                         | 3           |
| [`0x77`](#push24)         | PUSH24         | Place 24-byte item on stack                                                                                                                                  | -                                                                                                         | 3           |
| [`0x78`](#push25)         | PUSH25         | Place 25-byte item on stack                                                                                                                                  | -                                                                                                         | 3           |
| [`0x79`](#push26)         | PUSH26         | Place 26-byte item on stack                                                                                                                                  | -                                                                                                         | 3           |
| [`0x7a`](#push27)         | PUSH27         | Place 27-byte item on stack                                                                                                                                  | -                                                                                                         | 3           |
| [`0x7b`](#push28)         | PUSH28         | Place 28-byte item on stack                                                                                                                                  | -                                                                                                         | 3           |
| [`0x7c`](#push29)         | PUSH29         | Place 29-byte item on stack                                                                                                                                  | -                                                                                                         | 3           |
| [`0x7d`](#push30)         | PUSH30         | Place 30-byte item on stack                                                                                                                                  | -                                                                                                         | 3           |
| [`0x7e`](#push31)         | PUSH31         | Place 31-byte item on stack                                                                                                                                  | -                                                                                                         | 3           |
| [`0x7f`](#push32)         | PUSH32         | Place 32-byte (full word) item on stack                                                                                                                      | -                                                                                                         | 3           |
| [`0x80`](#dup1)           | DUP1           | Duplicate 1st stack item                                                                                                                                     | -                                                                                                         | 3           |
| [`0x81`](#dup2)           | DUP2           | Duplicate 2nd stack item                                                                                                                                     | -                                                                                                         | 3           |
| [`0x82`](#dup3)           | DUP3           | Duplicate 3rd stack item                                                                                                                                     | -                                                                                                         | 3           |
| [`0x83`](#dup4)           | DUP4           | Duplicate 4th stack item                                                                                                                                     | -                                                                                                         | 3           |
| [`0x84`](#dup5)           | DUP5           | Duplicate 5th stack item                                                                                                                                     | -                                                                                                         | 3           |
| [`0x85`](#dup6)           | DUP6           | Duplicate 6th stack item                                                                                                                                     | -                                                                                                         | 3           |
| [`0x86`](#dup7)           | DUP7           | Duplicate 7th stack item                                                                                                                                     | -                                                                                                         | 3           |
| [`0x87`](#dup8)           | DUP8           | Duplicate 8th stack item                                                                                                                                     | -                                                                                                         | 3           |
| [`0x88`](#dup9)           | DUP9           | Duplicate 9th stack item                                                                                                                                     | -                                                                                                         | 3           |
| [`0x89`](#dup10)          | DUP10          | Duplicate 10th stack item                                                                                                                                    | -                                                                                                         | 3           |
| [`0x8a`](#dup11)          | DUP11          | Duplicate 11th stack item                                                                                                                                    | -                                                                                                         | 3           |
| [`0x8b`](#dup12)          | DUP12          | Duplicate 12th stack item                                                                                                                                    | -                                                                                                         | 3           |
| [`0x8c`](#dup13)          | DUP13          | Duplicate 13th stack item                                                                                                                                    | -                                                                                                         | 3           |
| [`0x8d`](#dup14)          | DUP14          | Duplicate 14th stack item                                                                                                                                    | -                                                                                                         | 3           |
| [`0x8e`](#dup15)          | DUP15          | Duplicate 15th stack item                                                                                                                                    | -                                                                                                         | 3           |
| [`0x8f`](#dup16)          | DUP16          | Duplicate 16th stack item                                                                                                                                    | -                                                                                                         | 3           |
| [`0x90`](#swap1)          | SWAP1          | Exchange 1st and 2nd stack items                                                                                                                             | -                                                                                                         | 3           |
| [`0x91`](#swap2)          | SWAP2          | Exchange 1st and 3rd stack items                                                                                                                             | -                                                                                                         | 3           |
| [`0x92`](#swap3)          | SWAP3          | Exchange 1st and 4th stack items                                                                                                                             | -                                                                                                         | 3           |
| [`0x93`](#swap4)          | SWAP4          | Exchange 1st and 5th stack items                                                                                                                             | -                                                                                                         | 3           |
| [`0x94`](#swap5)          | SWAP5          | Exchange 1st and 6th stack items                                                                                                                             | -                                                                                                         | 3           |
| [`0x95`](#swap6)          | SWAP6          | Exchange 1st and 7th stack items                                                                                                                             | -                                                                                                         | 3           |
| [`0x96`](#swap7)          | SWAP7          | Exchange 1st and 8th stack items                                                                                                                             | -                                                                                                         | 3           |
| [`0x97`](#swap8)          | SWAP8          | Exchange 1st and 9th stack items                                                                                                                             | -                                                                                                         | 3           |
| [`0x98`](#swap9)          | SWAP9          | Exchange 1st and 10th stack items                                                                                                                            | -                                                                                                         | 3           |
| [`0x99`](#swap10)         | SWAP10         | Exchange 1st and 11th stack items                                                                                                                            | -                                                                                                         | 3           |
| [`0x9a`](#swap11)         | SWAP11         | Exchange 1st and 12th stack items                                                                                                                            | -                                                                                                         | 3           |
| [`0x9b`](#swap12)         | SWAP12         | Exchange 1st and 13th stack items                                                                                                                            | -                                                                                                         | 3           |
| [`0x9c`](#swap13)         | SWAP13         | Exchange 1st and 14th stack items                                                                                                                            | -                                                                                                         | 3           |
| [`0x9d`](#swap14)         | SWAP14         | Exchange 1st and 15th stack items                                                                                                                            | -                                                                                                         | 3           |
| [`0x9e`](#swap15)         | SWAP15         | Exchange 1st and 16th stack items                                                                                                                            | -                                                                                                         | 3           |
| [`0x9f`](#swap16)         | SWAP16         | Exchange 1st and 17th stack items                                                                                                                            | -                                                                                                         | 3           |
| [`0xa0`](#log0)           | LOG0           | Append log record with no topics                                                                                                                             | -                                                                                                         | 375         |
| [`0xa1`](#log1)           | LOG1           | Append log record with one topic                                                                                                                             | -                                                                                                         | 750         |
| [`0xa2`](#log2)           | LOG2           | Append log record with two topics                                                                                                                            | -                                                                                                         | 1125        |
| [`0xa3`](#log3)           | LOG3           | Append log record with three topics                                                                                                                          | -                                                                                                         | 1500        |
| [`0xa4`](#log4)           | LOG4           | Append log record with four topics                                                                                                                           | -                                                                                                         | 1875        |
| `0xa5` - `0xaf`           | Unused         | -                                                                                                                                                            |
| `0xb0`                    | JUMPTO         | Tentative [libevmasm has different numbers](https://github.com/ethereum/solidity/blob/c61610302aa2bfa029715b534719d25fe3949059/libevmasm/Instruction.h#L176) | [EIP 615](https://github.com/ethereum/EIPs/blob/606405b5ab7aa28d8191958504e8aad4649666c9/EIPS/eip-615.md) |
| `0xb1`                    | JUMPIF         | Tentative                                                                                                                                                    | [EIP 615](https://github.com/ethereum/EIPs/blob/606405b5ab7aa28d8191958504e8aad4649666c9/EIPS/eip-615.md) |
| `0xb2`                    | JUMPSUB        | Tentative                                                                                                                                                    | [EIP 615](https://github.com/ethereum/EIPs/blob/606405b5ab7aa28d8191958504e8aad4649666c9/EIPS/eip-615.md) |
| `0xb4`                    | JUMPSUBV       | Tentative                                                                                                                                                    | [EIP 615](https://github.com/ethereum/EIPs/blob/606405b5ab7aa28d8191958504e8aad4649666c9/EIPS/eip-615.md) |
| `0xb5`                    | BEGINSUB       | Tentative                                                                                                                                                    | [EIP 615](https://github.com/ethereum/EIPs/blob/606405b5ab7aa28d8191958504e8aad4649666c9/EIPS/eip-615.md) |
| `0xb6`                    | BEGINDATA      | Tentative                                                                                                                                                    | [EIP 615](https://github.com/ethereum/EIPs/blob/606405b5ab7aa28d8191958504e8aad4649666c9/EIPS/eip-615.md) |
| `0xb8`                    | RETURNSUB      | Tentative                                                                                                                                                    | [EIP 615](https://github.com/ethereum/EIPs/blob/606405b5ab7aa28d8191958504e8aad4649666c9/EIPS/eip-615.md) |
| `0xb9`                    | PUTLOCAL       | Tentative                                                                                                                                                    | [EIP 615](https://github.com/ethereum/EIPs/blob/606405b5ab7aa28d8191958504e8aad4649666c9/EIPS/eip-615.md) |
| `0xba`                    | GETLOCAL       | Tentative                                                                                                                                                    | [EIP 615](https://github.com/ethereum/EIPs/blob/606405b5ab7aa28d8191958504e8aad4649666c9/EIPS/eip-615.md) |
| `0xbb` - `0xe0`           | Unused         | -                                                                                                                                                            |
| `0xe1`                    | SLOADBYTES     | Only referenced in pyethereum                                                                                                                                | -                                                                                                         | -           |
| `0xe2`                    | SSTOREBYTES    | Only referenced in pyethereum                                                                                                                                | -                                                                                                         | -           |
| `0xe3`                    | SSIZE          | Only referenced in pyethereum                                                                                                                                | -                                                                                                         | -           |
| `0xe4` - `0xef`           | Unused         | -                                                                                                                                                            |
| [`0xf0`](#create)         | CREATE         | Create a new account with associated code                                                                                                                    | -                                                                                                         | 32000       |
| [`0xf1`](#call)           | CALL           | Message-call into an account                                                                                                                                 | -                                                                                                         | Complicated |
| [`0xf2`](#callcode)       | CALLCODE       | Message-call into this account with alternative account's code                                                                                               | -                                                                                                         | Complicated |
| [`0xf3`](#return)         | RETURN         | Halt execution returning output data                                                                                                                         | -                                                                                                         | 0           |
| [`0xf4`](#delegatecall)   | DELEGATECALL   | Message-call into this account with an alternative account's code, but persisting into this account with an alternative account's code                       | -                                                                                                         | Complicated |
| [`0xf5`](#create2)        | CREATE2        | Create a new account and set creation address to `sha3(sender + sha3(init code)) % 2**160`                                                                   | -                                                                                                         |
| `0xf6` - `0xf9`           | Unused         | -                                                                                                                                                            | -                                                                                                         |
| [`0xfa`](#staticcall)     | STATICCALL     | Similar to CALL, but does not modify state                                                                                                                   | -                                                                                                         | 40          |
| `0xfb`                    | Unused         | -                                                                                                                                                            | -                                                                                                         |
| [`0xfd`](#revert)         | REVERT         | Stop execution and revert state changes, without consuming all provided gas and providing a reason                                                           | -                                                                                                         | 0           |
| `0xfe`                    | INVALID        | Designated invalid instruction                                                                                                                               | -                                                                                                         | 0           |
| [`0xff`](#selfdestruct)   | SELFDESTRUCT   | Halt execution and register account for later deletion                                                                                                       | -                                                                                                         | 5000\*      |

## Instruction Details

---

### STOP

**0x00**

() => ()

halts execution

---

### ADD

**0x01**

Takes two words from stack, adds them, then pushes the result onto the stack.

(a, b) => (c)

c = a + b

---

### MUL

**0x02**

(a, b) => (c)

c = a \* b

---

### SUB

**0x03**

(a, b) => (c)

c = a - b

---

### DIV

**0x04**

(a, b) => (c)

c = a / b

---

### SDIV

**0x05**

(a: int256, b: int256) => (c: int256)

c = a / b

---

### MOD

**0x06**

(a, b) => (c)

c = a % b

---

### SMOD

**0x07**

(a: int256, b: int256) => (c: int256)

c = a % b

---

### ADDMOD

**0x08**

(a, b, m) => (c)

c = (a + b) % m

---

### MULMOD

**0x09**

(a, b, m) => (c)

c = (a \* b) % m

---

### EXP

**0x0a**

(a, b, m) => (c)

c = (a \* b) % m

---

### SIGNEXTEND

**0x0b**

(b, x) => (y)

y = SIGNEXTEND(x, b)

sign extends x from (b + 1) \* 8 bits to 256 bits.

---

### LT

**0x10**

(a, b) => (c)

c = a < b

all values interpreted as uint256

---

### GT

**0x11**

(a, b) => (c)

c = a > b

all values interpreted as uint256

---

### SLT

**0x12**

(a, b) => (c)

c = a < b

all values interpreted as int256

---

### SGT

**0x13**

(a, b) => (c)

c = a > b

all values interpreted as int256

---

### EQ

**0x14**

Pops 2 elements off the stack and pushes the value 1 to the stack in case they're equal, otherwise the value 0.

(a, b) => (c)

c = a == b

---

### ISZERO

**0x15**

(a) => (c)

c = a == 0

---

### AND

**0x16**

(a, b) => (c)

c = a & b

---

### OR

**0x17**

(a, b) => (c)

c = a | b

---

### XOR

**0x18**

(a, b) => (c)

c = a ^ b

---

### NOT

**0x19**

(a) => (c)

c = ~a

---

### BYTE

**0x1a**

(i, x) => (y)

y = (x >> (248 - i \* 8) & 0xff

---

### SHL

**0x1b**

Pops 2 elements from the stack and pushes the second element onto the stack shifted left by the shift amount (first element).

(shift, value) => (res)

res = value << shift

---

### SHR

**0x1c**

Pops 2 elements from the stack and pushes the second element onto the stack shifted right by the shift amount (first element).

(shift, value) => (res)

res = value >> shift

---

### SAR

**0x1d**

(shift, value) => (res)

res = value >> shift

value: int256

---

### KECCAK256

**0x20**

(offset, len) => (hash)

hash = keccak256(memory[offset:offset+len])

---

### ADDRESS

**0x30**

() => (address(this))

---

### BALANCE

**0x31**

() => (address(this).balance)

---

### ORIGIN

**0x32**

() => (tx.origin)

---

### CALLER

**0x33**

() => (msg.sender)

---

### CALLVALUE

**0x34**

() => (msg.value)

---

### CALLDATALOAD

**0x35**

(index) => (msg.data[index:index+32])

---

### CALLDATASIZE

**0x36**

() => (msg.data.size)

---

### CALLDATACOPY

**0x37**

(memOffset, offset, length) => ()

memory[memOffset:memOffset+len] = msg.data[offset:offset+len]

---

### CODESIZE

**0x38**

() => (address(this).code.size)

---

### CODECOPY

**0x39**

(memOffset, codeOffset, len) => ()

memory[memOffset:memOffset+len] = address(this).code[codeOffset:codeOffset+len]

---

### GASPRICE

**0x3a**

() => (tx.gasprice)

---

### EXTCODESIZE

**0x3b**

(addr) => (address(addr).code.size)

---

### EXTCODECOPY

**0x3c**

(addr, memOffset, offset, length) => ()

memory[memOffset:memOffset+len] = address(addr).code[codeOffset:codeOffset+len]

---

### RETURNDATASIZE

**0x3d**

() => (size)

size = RETURNDATASIZE()

The number of bytes that were returned from the last ext call

---

### RETURNDATACOPY

**0x3e**

(memOffset, offset, length) => ()

memory[memOffset:memOffset+len] = RETURNDATA[codeOffset:codeOffset+len]

RETURNDATA is the data returned from the last external call

---

### EXTCODEHASH

**0x3f**

(addr) => (hash)

hash = address(addr).exists ? keccak256(address(addr).code) : 0

---

### BLOCKHASH

**0x40**

(number) => (hash)

hash = block.blockHash(number)

---

### COINBASE

**0x41**

() => (block.coinbase)

---

### TIMESTAMP

**0x42**

() => (block.timestamp)

---

### NUMBER

**0x43**

() => (block.number)

---

### DIFFICULTY

**0x44**

() => (block.difficulty)

---

### GASLIMIT

**0x45**

() => (block.gaslimit)

---

### CHAINID

**0x46**

() => (chainid)

where chainid = 1 for mainnet & some other value for other networks

---

### SELFBALANCE

**0x47**

() => (address(this).balance)

---

### BASEFEE

**0x48**

() => (block.basefee)

current block's base fee (related to EIP1559)

---

### POP

**0x50**

(a) => ()

discards the top stack item

---

### MLOAD

**0x51**

(offset) => (value)

value = memory[offset:offset+32]

---

### MSTORE

**0x52**

Saves a word to the EVM memory. Pops 2 elements from stack - the first element being the word memory address where the saved value (second element popped from stack) will be stored.

(offset, value) => ()

memory[offset:offset+32] = value

---

### MSTORE8

**0x53**

(offset, value) => ()

memory[offset:offset+32] = value & 0xff

---

### SLOAD

**0x54**

Pops 1 element off the stack, that being the key which is the storage slot and returns the read value stored there.

(key) => (value)

value = storage[key]

---

### SSTORE

**0x55**

Pops 2 elements off the stack, the first element being the key and the second being the value which is then stored at the storage slot represented from the first element (key).

(key, value) => ()

storage[key] = value

---

### JUMP

**0x56**

(dest) => ()

pc = dest

---

### JUMPI

**0x57**

Conditional - Pops 2 elements from the stack, the first element being the jump location and the second being the value 0 (false) or 1 (true). If the value’s 1 the PC will be altered and the jump executed. Otherwise, the value will be 0 and the PC will remain the same and execution unaltered.

(dest, cond) => ()

pc = cond ? dest : pc + 1

---

### PC

**0x58**

() => (pc)

---

### MSIZE

**0x59**

() => (memory.size)

---

### GAS

**0x5a**

() => (gasRemaining)

not including the gas required for this opcode

---

### JUMPDEST

**0x5b**

() => ()

noop, marks a valid jump destination

---

### PUSH0

**0x5f**

The constant value 0 is pushed onto the stack.

() => (0)

---

### PUSH1

**0x60**

The following byte is read from PC, placed into a word, then this word is pushed onto the stack.

() => (address(this).code[pc+1:pc+2])

---

### PUSH2

**0x61**

() => (address(this).code[pc+2:pc+3])

---

### PUSH3

**0x62**

() => (address(this).code[pc+3:pc+4])

---

### PUSH4

**0x63**

() => (address(this).code[pc+4:pc+5])

---

### PUSH5

**0x64**

() => (address(this).code[pc+5:pc+6])

---

### PUSH6

**0x65**

() => (address(this).code[pc+6:pc+7])

---

### PUSH7

**0x66**

() => (address(this).code[pc+7:pc+8])

---

### PUSH8

**0x67**

() => (address(this).code[pc+8:pc+9])

---

### PUSH9

**0x68**

() => (address(this).code[pc+9:pc+10])

---

### PUSH10

**0x69**

() => (address(this).code[pc+10:pc+11])

---

### PUSH11

**0x6a**

() => (address(this).code[pc+11:pc+12])

---

### PUSH12

**0x6b**

() => (address(this).code[pc+12:pc+13])

---

### PUSH13

**0x6c**

() => (address(this).code[pc+13:pc+14])

---

### PUSH14

**0x6d**

() => (address(this).code[pc+14:pc+15])

---

### PUSH15

**0x6e**

() => (address(this).code[pc+15:pc+16])

---

### PUSH16

**0x6f**

() => (address(this).code[pc+16:pc+17])

---

### PUSH17

**0x70**

() => (address(this).code[pc+17:pc+18])

---

### PUSH18

**0x71**

() => (address(this).code[pc+18:pc+19])

---

### PUSH19

**0x72**

() => (address(this).code[pc+19:pc+20])

---

### PUSH20

**0x73**

() => (address(this).code[pc+20:pc+21])

---

### PUSH21

**0x74**

() => (address(this).code[pc+21:pc+22])

---

### PUSH22

**0x75**

() => (address(this).code[pc+22:pc+23])

---

### PUSH23

**0x76**

() => (address(this).code[pc+23:pc+24])

---

### PUSH24

**0x77**

() => (address(this).code[pc+24:pc+25])

---

### PUSH25

**0x78**

() => (address(this).code[pc+25:pc+26])

---

### PUSH26

**0x79**

() => (address(this).code[pc+26:pc+27])

---

### PUSH27

**0x7a**

() => (address(this).code[pc+27:pc+28])

---

### PUSH28

**0x7b**

() => (address(this).code[pc+28:pc+29])

---

### PUSH29

**0x7c**

() => (address(this).code[pc+29:pc+30])

---

### PUSH30

**0x7d**

() => (address(this).code[pc+30:pc+31])

---

### PUSH31

**0x7e**

() => (address(this).code[pc+31:pc+32])

---

### PUSH32

**0x7f**

() => (address(this).code[pc+32:pc+33])

---

### DUP1

**0x80**

(1) => (1, 1)

---

### DUP2

**0x81**

(1, 2) => (2, 1, 2)

---

### DUP3

**0x82**

(1, 2, 3) => (3, 1, 2, 3)

---

### DUP4

**0x83**

(1, ..., 4) => (4, 1, ..., 4)

---

### DUP5

**0x84**

(1, ..., 5) => (5, 1, ..., 5)

---

### DUP6

**0x85**

(1, ..., 6) => (6, 1, ..., 6)

---

### DUP7

**0x86**

(1, ..., 7) => (7, 1, ..., 7)

---

### DUP8

**0x87**

(1, ..., 8) => (8, 1, ..., 8)

---

### DUP9

**0x88**

(1, ..., 9) => (9, 1, ..., 9)

---

### DUP10

**0x89**

(1, ..., 10) => (10, 1, ..., 10)

---

### DUP11

**0x8a**

(1, ..., 11) => (11, 1, ..., 11)

---

### DUP12

**0x8b**

(1, ..., 12) => (12, 1, ..., 12)

---

### DUP13

**0x8c**

(1, ..., 13) => (13, 1, ..., 13)

---

### DUP14

**0x8d**

(1, ..., 14) => (14, 1, ..., 14)

---

### DUP15

**0x8e**

(1, ..., 15) => (15, 1, ..., 15)

---

### DUP16

**0x8f**

(1, ..., 16) => (16, 1, ..., 16)

---

### SWAP1

**0x90**

(1, 2) => (2, 1)

---

### SWAP2

**0x91**

(1, 2, 3) => (3, 2, 1)

---

### SWAP3

**0x92**

(1, ..., 4) => (4, ..., 1)

---

### SWAP4

**0x93**

(1, ..., 5) => (5, ..., 1)

---

### SWAP5

**0x94**

(1, ..., 6) => (6, ..., 1)

---

### SWAP6

**0x95**

(1, ..., 7) => (7, ..., 1)

---

### SWAP7

**0x96**

(1, ..., 8) => (8, ..., 1)

---

### SWAP8

**0x97**

(1, ..., 9) => (9, ..., 1)

---

### SWAP9

**0x98**

(1, ..., 10) => (10, ..., 1)

---

### SWAP10

**0x99**

(1, ..., 11) => (11, ..., 1)

---

### SWAP11

**0x9a**

(1, ..., 12) => (12, ..., 1)

---

### SWAP12

**0x9b**

(1, ..., 13) => (13, ..., 1)

---

### SWAP13

**0x9c**

(1, ..., 14) => (14, ..., 1)

---

### SWAP14

**0x9d**

(1, ..., 15) => (15, ..., 1)

---

### SWAP15

**0x9e**

(1, ..., 16) => (16, ..., 1)

---

### SWAP16

**0x9f**

(1, ..., 17) => (17, ..., 1)

---

### LOG0

**0xa0**

(offset, length) => ()

emit(memory[offset:offset+length])

---

### LOG1

**0xa1**

(offset, length, topic0) => ()

emit(memory[offset:offset+length], topic0)

---

### LOG2

**0xa2**

(offset, length, topic0, topic1) => ()

emit(memory[offset:offset+length], topic0, topic1)

---

### LOG3

**0xa3**

(offset, length, topic0, topic1, topic2) => ()

emit(memory[offset:offset+length], topic0, topic1, topic2)

---

### LOG4

**0xa4**

(offset, length, topic0, topic1, topic2, topic3) => ()

emit(memory[offset:offset+length], topic0, topic1, topic2, topic3)

---

### CREATE

**0xf0**

(value, offset, length) => (addr)

addr = keccak256(rlp([address(this), this.nonce]))[12:]
addr.code = exec(memory[offset:offset+length])
addr.balance += value
this.balance -= value
this.nonce += 1

---

### CALL

**0xf1**

(gas, addr, value, argsOffset, argsLength, retOffset, retLength) => (success)

memory[retOffset:retOffset+retLength] = address(addr).callcode.gas(gas).value(value)(memory[argsOffset:argsOffset+argsLength])
success = true (unless the prev call reverted)

---

### CALLCODE

**0xf2**

(gas, addr, value, argsOffset, argsLength, retOffset, retLength) => (success)

memory[retOffset:retOffset+retLength] = address(addr).callcode.gas(gas).value(value)(memory[argsOffset:argsOffset+argsLength])
success = true (unless the prev call reverted)

TODO: what's the difference between this & CALL?

---

### RETURN

**0xf3**

(offset, length) => ()

return memory[offset:offset+length]

---

### DELEGATECALL

**0xf4**

(gas, addr, argsOffset, argsLength, retOffset, retLength) => (success)

memory[retOffset:retOffset+retLength] = address(addr).delegatecall.gas(gas)(memory[argsOffset:argsOffset+argsLength])
success = true (unless the prev call reverted)

---

### CREATE2

**0xf5**

(value, offset, length, salt) => (addr)

initCode = memory[offset:offset+length]
addr = keccak256(0xff ++ address(this) ++ salt ++ keccak256(initCode))[12:]
address(addr).code = exec(initCode)

---

### STATICCALL

**0xfa**

(gas, addr, argsOffset, argsLength, retOffset, retLength) => (success)

memory[retOffset:retOffset+retLength] = address(addr).delegatecall.gas(gas)(memory[argsOffset:argsOffset+argsLength])
success = true (unless the prev call reverted)

TODO: what's the difference between this & DELEGATECALL?

---

### REVERT

**0xfd**

(offset, length) => ()

revert(memory[offset:offset+length])

---

### SELFDESTRUCT

**0xff**

(addr) => ()

address(addr).send(address(this).balance)
this.code = 0
