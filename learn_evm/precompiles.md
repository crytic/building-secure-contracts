# What are precompiles?

Precompiles are a unique class of contracts that can be executed at a predetermined gas cost. They are packaged with the EVM at fixed addresses beginning at 0x01 and increasing for each new precompile. Like regular contracts, they are called by their addresses using commands like CALL or STATICCALL.

Precompiles include algorithms that can be computationally intensive if implemented directly in Ethereum smart contracts using Ethereum's native bytecode. Precompiles provide optimized implementations for these operations, making them more efficient and cost-effective.

**Precompiles in go-ethereum**

The specification for a precompile in go-ethereum is an [interface](https://github.com/ethereum/go-ethereum/blob/master/core/vm/contracts.go#L41-L44) containing two fields:
![carbon](https://github.com/crytic/building-secure-contracts/assets/19494452/7891cff5-4c06-4aeb-b846-24d6b08e3544)
- **RequiredGas:** calculates and returns the gas cost for executing the precompiled contract with given input parameters.
- **Run:** this is the actual implementation of the precompile. It takes input data and returns output data along with any gas refunds if applicable.

All precompiles in go-ethereum live in [contracts.go](https://github.com/ethereum/go-ethereum/blob/master/core/vm/contracts.go)


**List of hard forks and their precompiles**

The list will only include hard forks that introduced new precompiles. The precompiles for each hard fork are listed in order of their addresses, starting with the precompile at the 0x01 address.

**NOTE:**

Throughout this list, **data\_word\_size** is calculated as (data\_size + 31) / 32, where data\_size is the size of the input provided to the precompile.





## Homestead:

1. **ecRecover:** Used to extract a digital signature and address from a hash and identifies the signer if the signature is valid.
   1. **Static gas:** 3000
   1. **Dynamic gas:** nil
   1. **Input:** hash, v, r, s
   1. **Output:** Address of the signer
1. **SHA-256:** Returns a sha256 hash of the bytes supplied in the calldata.
   1. **Static gas:** 60
   1. **Dynamic gas:** 12 \* data\_word\_size
   1. **Input:** Bytes to be hashed
   1. **Output:** Hash
1. **RIPEMD-256:** Similar to the preceding precompile, returns a hash of the bytes supplied to it.
   1. **Static gas:** 600
   1. **Dynamic gas:** 120 \* data\_word\_size
   1. **Input:** Bytes to be hashed
   1. **Output:** Hash
1. **ID:** Copies one region of memory to another.
   1. **Static gas:** 15
   1. **Dynamic gas:** 3 \* data\_word\_size
   1. **Input:** Memory address
   1. **Output:** Memory address provided as input
1. **modExp (Introduced in EIP-198):** Used for modular exponentiation. Modular exponentiation is used in various cryptographic algorithms such as RSA and may be used by smart contracts for cryptographic purposes or to compute large powers efficiently.
   1. **Gas cost:** The gas cost is calculated based on the complexity and is as follows, where x is the length of the input:
      1. If x <= 64, complexity = x^2.
      1. If 64 < x <= 1024, complexity = x^2 // 4 + 96x - 3072.
      1. Otherwise, complexity = x^2 // 16 + 480x - 199680.
   1. **Input:** Three integers: base, exponent, and modulus.
   1. **Output:** The result of base^exponent % modulus.





## Byzantium:

**1-5:** Same as previous fork

**6. ecAdd (Introduced in EIP-196):** Performs elliptic curve point addition.

1. **Static gas:** 150
1. **Dynamic gas:** nil 
1. **Input:** Two elliptic curve points, P and Q, encoded as 64-byte values (X and Y coordinates).
1. **Output:** The resulting point R = P + Q, encoded as a 64-byte value (X and Y coordinates).

**7. ecMul (Introduced in EIP-196):** Performs elliptic curve point scalar multiplication.

1. **Static gas:** 6000
1. **Dynamic gas:** nil
1. **Input:** An elliptic curve point P, encoded as a 64-byte value (X and Y coordinates), and a scalar k.
1. **Output:** The resulting point R = kP, encoded as a 64-byte value (X and Y coordinates).

**8. ecPairing (Introduced in EIP-197):** Performs an elliptic curve pairing operation.

1. **Minimum gas:** 45000
1. **Input:** A list of elliptic curve points: (P1, Q1, P2, Q2, …, Pn, Qn), encoded as 64-byte values, where each pair represents a point on an elliptic curve.
1. **Output:** A single 32-byte value representing the result of the pairing operation.
   1. If the pairing is valid (e.g., e(P1, Q1) \* e(P2, Q2) \* … \* e(Pn, Qn) = 1), the output is 1.
   1. Otherwise, the output is 0.



## Istanbul:

**1-8:** Same as the previous fork

**9. Blake2f (Introduced in EIP-152):** Implements the compression function used in the BLAKE2 cryptographic hashing algorithm, to allow interoperability between the EVM and Zcash, as well as introducing more flexible cryptographic hash primitives to the EVM.

1. **Static gas:** 0
1. **Dynamic gas:** rounds \* 1
1. **Input:** It takes in 6 inputs, namely:
   1. **rounds**: The number of rounds (32-bit unsigned big-endian word).
   1. **h**: The state vector (8 unsigned 64-bit little-endian words).
   1. **m**: The message block vector (16 unsigned 64-bit little-endian words).
   1. **t\_0**, **t\_1**: Offset counters (2 unsigned 64-bit little-endian words).
   1. **f**: The final block indicator flag (8-bit word).
      1. Encoded as: [4 bytes for rounds] [64 bytes for h] [128 bytes for m] [8 bytes for t\_0] [8 bytes for t\_1] [1 byte for f]
      1. The boolean f parameter is considered true if set to 1, and false if set to 0.
1. **Output:** After processing the inputs, it returns a 64-byte output.



## Berlin:

**1-9:** Same as the previous fork

The **Berlin** hard fork contains the same precompiles as the previous fork but changed the implementation details (in EIP-2565) of the **modExp** precompile which made it more efficient and practical. The new gas cost considers the **multiplication complexity** based on the lengths of the base and modulus and also an approximation of the number of **iterations** required for the exponentiation.

**Updated gas cost for modExp:** max(200, floor(multiplication\_complexity \* iteration\_count / 3))

**10. Point Evaluation (stored at the 0x0a address) [Introduced in EIP-4844]:** Used to verify a KZG (Kate-Zaverucha-Goldberg) proof. This proof demonstrates that at a specific point, a blob represented by a commitment evaluates to a given value.

1. **Gas cost: 50000**
1. **Input:** It takes in 6 inputs, namely:
   1. **rounds**: Number of rounds (32-bit unsigned big-endian word).
   1. **h**: State vector (8 unsigned 64-bit little-endian words).
   1. **m**: Message block vector (16 unsigned 64-bit little-endian words).
   1. **t\_0**, **t\_1**: Offset counters (2 unsigned 64-bit little-endian words).
   1. **f**: Final block indicator flag (8-bit word).
1. **Output:** Returns the value obtained from processing the inputs.


## Cancun [current]:

**1-9:** Same as the previous fork

The 10th precompile (point evaluation) introduced in the **Berlin** fork was removed in the **Cancun** fork.

