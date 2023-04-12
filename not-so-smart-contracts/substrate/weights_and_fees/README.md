# Weights and Fees

Weights and transaction fees are the two primary methods for regulating the consumption of blockchain resources. Overusing blockchain resources can enable a malicious actor to spam the network, resulting in a denial-of-service (DoS) attack. Weights manage the time it takes to validate a block. The larger the weight, the more time and resources the computation requires. Transaction fees provide an economic incentive to limit resource usage for operations. The fee for a given transaction depends on the weight required by the transaction.

Weights can be fixed or use a custom "weight annotation/function." A weight function might calculate the weight based on the number of database reads/writes and the size of the input parameters (e.g., a long `Vec<>`). To optimize the weight, ensuring users don't pay too little or too much for a transaction, benchmarking can be used to empirically determine the correct weight in worst-case scenarios.

Specifying the accurate weight function and benchmarking it is vital to protect the Substrate node from DoS attacks. Since fees depend on weight, a poorly defined weight function implies incorrect fees. For example, if a function performs heavy computation (requiring much time) but specifies a minimal weight, that function is cheap to call. In this case, an attacker can execute a low-cost attack while still stealing a substantial amount of block execution time, preventing regular transactions from being included in those blocks.

# Example

In the [`pallet-bad-weights`](https://github.com/crytic/building-secure-contracts/blob/master/not-so-smart-contracts/substrate/weights_and_fees/pallet-bad-weights.rs) pallet, a custom weight function, `MyWeightFunction`, calculates the weight for a call to `do_work`. The weight required for calling `do_work` is `10_000_000` times the length of the `useful_amounts` vector.

```rust
impl WeighData<(&Vec<u64>,)> for MyWeightFunction {
    fn weigh_data(&self, (amounts,): (&Vec<u64>,)) -> Weight {
        self.0.saturating_mul(amounts.len() as u64).into()
    }
}
```

However, if the length of the `useful_amounts` vector is zero, the weight for calling `do_work` is also zero. A weight of zero implies that the function is financially cheap to call. This situation opens up opportunities for an attacker to call `do_work` numerous times, saturating the network with malicious transactions without paying a large fee, potentially causing a DoS attack.

One possible solution is to set a fixed weight if the length of `useful_amounts` is zero.

```rust
impl WeighData<(&Vec<u64>,)> for MyWeightFunction {
    fn weigh_data(&self, (amounts,): (&Vec<u64>,)) -> Weight {
        // The weight function is `y = mx + b` where `m` and `b` are both `self.0` (the static fee) and `x` is the length of the `amounts` array.
        // If `amounts.len() == 0`, then the weight is simply the static fee (i.e., `y = b`)
        self.0 + self.0.saturating_mul(amounts.len() as u64).into()
    }
}
```

In the example above, if the length of `amounts` (i.e., `useful_amounts`) is zero, the function returns `self.0` (i.e., `10_000_000`).

On the other hand, if an attacker submits a `useful_amounts` vector with an incredibly large size, the returned `Weight` could become so large that the dispatchable consumes a significant amount of block execution time, preventing other transactions from fitting into the block. A solution would be to set an upper limit on the maximum allowable length for `useful_amounts`.

**Note**: Custom _fee_ functions can also be created. These functions should be carefully evaluated and tested to ensure that they mitigate the risk of DoS attacks.

# Mitigations

- Use [benchmarking](https://docs.substrate.io/main-docs/test/benchmark/) to empirically test the computational resources utilized by various dispatchable functions. Use benchmarking to define lower and upper weight bounds for each dispatchable.
- Create limits for input arguments to prevent a transaction from consuming too many computational resources. For example, if a `Vec<>` is an input argument to a function, restrict the length of the `Vec<>` to prevent it from becoming excessively large.
- Be cautious with fixed-weight dispatchables (e.g., `#[pallet::weight(1_000_000)]`). A weight that doesn't consider database reads/writes or input parameters may expose the system to DoS attacks.

# References

- https://docs.substrate.io/main-docs/build/tx-weights-fees/
- https://docs.substrate.io/reference/how-to-guides/weights/add-benchmarks/
- https://docs.substrate.io/reference/how-to-guides/weights/use-custom-weights/
- https://docs.substrate.io/reference/how-to-guides/weights/use-conditional-weights/
- https://www.shawntabrizi.com/substrate/substrate-weight-and-fees/
