# Weights and Fees

Weights and transaction fees are the two main ways to regulate the consumption of blockchain resources. The overuse of blockchain resources can allow a malicious actor to spam the network to cause a denial-of-service (DoS). Weights are used to manage the time it takes to validate the block. The larger the weight, the more "resources" / time the computation takes. Transaction fees provide an economic incentive to limit the number of resources used to perform operations; the fee for a given transaction is a function of the weight required by the transaction.

Weights can be fixed or a custom "weight annotation / function" can be implemented. A weight function can calculate the weight, for example, based on the number of database read / writes and the size of the input paramaters (e.g. a long `Vec<>`). To optimize the weight such that users do not pay too little or too much for a transaction, benchmarking can be used to empirically determine the correct weight in worst case scenarios.

Specifying the correct weight function and benchmarking it is crucial to protect the Substrate node from denial-of-service (DoS) attacks. Since fees are a function of weight, a bad weight function implies incorrect fees. For example, if some function performs heavy computation (which takes a lot of time) but specifies a very small weight, it is cheap to call that function. In this way an attacker can perform a low-cost attack while still stealing a large amount of block execution time. This will prevent regular transactions from being fit into those blocks.

# Example

In the [`pallet-bad-weights`](https://github.com/crytic/building-secure-contracts/blob/master/not-so-smart-contracts/substrate/weights_and_fees/pallet-bad-weights.rs) pallet, a custom weight function, `MyWeightFunction`, is used to calculate the weight for a call to `do_work`. The weight required for a call to `do_work` is `10_000_000` times the length of the `useful_amounts` vector.

```rust
impl WeighData<(&Vec<u64>,)> for MyWeightFunction {
    fn weigh_data(&self, (amounts,): (&Vec<u64>,)) -> Weight {
        self.0.saturating_mul(amounts.len() as u64).into()
    }
}
```

However, if the length of the `useful_amounts` vector is zero, the weight to call `do_work` would be zero. A weight of zero implies that calling this function is financially cheap. This opens the opportunity for an attacker to call `do_work` a large number of times to saturate the network with malicious transactions without having to pay a large fee and could cause a DoS attack.

One potential fix for this is to set a fixed weight if the length of `useful_amounts` is zero.

```rust
impl WeighData<(&Vec<u64>,)> for MyWeightFunction {
    fn weigh_data(&self, (amounts,): (&Vec<u64>,)) -> Weight {
        // The weight function is `y = mx + b` where `m` and `b` are both `self.0` (the static fee) and `x` is the length of the `amounts` array.
        // If `amounts.len() == 0` then the weight is simply the static fee (i.e. `y = b`)
        self.0 + self.0.saturating_mul(amounts.len() as u64).into()
    }
}
```

In the example above, if the length of `amounts` (i.e. `useful_amounts`) is zero, then the function will return `self.0` (i.e. `10_000_000`).

On the other hand, if an attacker sends a `useful_amounts` vector that is incredibly large, the returned `Weight` can become large enough such that the dispatchable takes up a large amount block execution time and prevents other transactions from being fit into the block. A fix for this would be to bound the maximum allowable length for `useful_amounts`.

**Note**: Custom _fee_ functions can also be created. These functions should also be carefully evaluated and tested to ensure that the risk of DoS attacks is mitigated.

# Mitigations

- Use [benchmarking](https://docs.substrate.io/main-docs/test/benchmark/) to empirically test the computational resources utilized by various dispatchable functions. Additionally, use benchmarking to define a lower and upper weight bound for each dispatchable.
- Create bounds for input arguments to prevent a transaction from taking up too many computational resources. For example, if a `Vec<>` is being taken as an input argument to a function, prevent the length of the `Vec<>` from being too large.
- Be wary of fixed weight dispatchables (e.g. `#[pallet::weight(1_000_000)]`). A weight that is completely agnostic to database read / writes or input parameters may open up avenues for DoS attacks.

# References

- https://docs.substrate.io/main-docs/build/tx-weights-fees/
- https://docs.substrate.io/reference/how-to-guides/weights/add-benchmarks/
