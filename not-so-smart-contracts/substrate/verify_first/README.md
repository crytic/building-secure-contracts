Goal here is to show that state changes should not be made before all potentially reverting operations have been validated:
Verify first, write last principle from [here](https://docs.substrate.io/main-docs/build/runtime-storage/)

Also, the mint function in this pallet is public, which can be problematic in itself.

Can make this not-so-smart-pallet contain two issues, I guess