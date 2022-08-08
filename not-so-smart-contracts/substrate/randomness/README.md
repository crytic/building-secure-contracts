Bad randomness choice by directly using `random_seed`. Click [here](https://docs.substrate.io/main-docs/build/randomness/#security-properties)


"The first implementation provided by Substrate is the [Randomness Collective Flip Pallet](https://paritytech.github.io/substrate/master/pallet_randomness_collective_flip/index.html). This pallet is based on collective coin flipping. It is quite performant, but not very secure. This pallet should be used only when testing randomness-consuming pallets, not it production."