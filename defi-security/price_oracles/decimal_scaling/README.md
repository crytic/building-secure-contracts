# Decimal Scaling Vulnerabilities

## Overview

Many smart contracts depend on external price oracles to obtain critical financial data. A common assumption is that these oracles always return values with 18 decimals. However, this is not guaranteed; different oracles may use a variable number of decimals. Relying on a fixed 18-decimal assumption can result in inaccurate computations, leading to mispriced transactions, incorrect reward calculations, and financial losses.

---

## Vulnerability Details

### Wrong Price Scaling 
Some contracts, multiply values from two different Chainlink oracles: one for the price (in ETH) and another for the USD value per ETH. Often, the code assumes both oracle responses are scaled to 18 decimals:

## Impact

- **Inaccurate Calculations**:  
  Incorrect scaling can result in either overestimating or underestimating important financial metrics.

- **Financial Losses**:  
  Users might be charged too much or too little, leading to loss of funds or improper fund allocation during transactions.

---

## Recommended Mitigation Steps

1. **Dynamic Decimal Adjustment**  
   - Query the oracle’s `decimals()` function to determine the actual number of decimals for each oracle response.
  
   - Avoid hardcoding decimal assumptions; instead, adjust calculations based on live data from the oracle.
---

## Conclusion

Relying on a fixed 18-decimal assumption for oracle data can lead to severe vulnerabilities and operational inconsistencies. By dynamically adjusting for the actual decimals reported by oracles and standardizing scaling across your contract, you can ensure accurate price calculations and protect users from  financial harm.
