# Arbitrary External Calls

Bridge facets that allow user-controlled call targets and calldata enable token theft.

## Description

Bridge aggregators often accept user-provided addresses and calldata to perform swap or bridge operations on behalf of users. This design allows flexibility, enabling the bridge to interact with multiple DEXs and protocols without deploying new code for each integration.

However, when the bridge contract holds token approvals from users, this flexibility becomes a critical vulnerability. An attacker can craft calldata that calls `transferFrom` on an approved token contract, redirecting funds from any user who has previously approved the bridge. The bridge executes the call without distinguishing between a legitimate swap and a malicious token transfer.

This vulnerability was exploited in production against the LiFi bridge. The root cause is the absence of a whitelist restricting which addresses the bridge can call and what function selectors are permitted in the calldata.

## Exploit Scenario

Alice approves the bridge contract to spend her USDC so she can perform a cross-chain swap. Bob calls `swapAndStartBridgeTokensGeneric()` on the same bridge contract, setting `callTo` to the USDC token address and `callData` to the ABI encoding of `transferFrom(alice, bob, amount)`. The bridge contract executes the arbitrary call, transferring Alice's USDC to Bob.

## Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableBridgeFacet {
    struct SwapData {
        address callTo;
        address approveTo;
        address sendingAssetId;
        address receivingAssetId;
        uint256 fromAmount;
        bytes callData;
    }

    // No whitelist on callTo or callData
    function _executeSwap(SwapData calldata _swap) internal {
        IERC20(_swap.sendingAssetId).approve(_swap.approveTo, _swap.fromAmount);

        // Arbitrary call: attacker can set callTo to any token address
        // and callData to transferFrom(victim, attacker, amount)
        (bool success, ) = _swap.callTo.call(_swap.callData);
        require(success, "Swap failed");
    }

    function swapAndStartBridgeTokensGeneric(
        SwapData calldata _swapData
    ) external payable {
        _executeSwap(_swapData);
    }
}
```

## Mitigations

- Whitelist allowed call targets and restrict calls to known, audited swap routers.
- Never allow arbitrary calldata to be forwarded to token contract addresses.
- Validate that `callTo` is not any token address held or approved by the contract.
- Use dedicated, purpose-built swap router interfaces instead of generic low-level calls.
- Strip or validate function selectors in calldata to prevent `transferFrom` and `approve` calls.
