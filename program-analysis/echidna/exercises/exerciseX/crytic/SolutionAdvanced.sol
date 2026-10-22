// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {NaughtCoin} from "../NaughtCoin.sol";
import {Setup} from "./SolutionSetupAdvanced.sol";

contract ExternalTestAdvanced is Setup {
    event AssertionFailed(uint256 amount);
    event Log(bytes data);

    function always_true() public pure {
        assert(true);
    }

    function token_should_be_deployed() public view {
        assert(address(token) != address(0));
    }

    function player_balance_is_equal_to_initial_supply() public view {
        assert(token.balanceOf(address(player)) == token.INITIAL_SUPPLY());
    }

    function token_transfer_should_fail_before_timelock_period(uint256 amount)
        public
    {
        amount = _between(amount, 0, token.INITIAL_SUPPLY());

        // pre-conditions
        uint256 currentTime = block.timestamp;
        uint256 playerBalanceBefore = token.balanceOf(address(player));
        uint256 bobBalanceBefore = token.balanceOf(address(bob));

        if (currentTime < token.timeLock()) {
            // action
            try
                player.proxy(
                    address(token),
                    abi.encodeWithSelector(
                        token.transfer.selector,
                        address(bob),
                        amount
                    )
                )
            returns (bool success, bytes memory returnData) {
                emit Log(returnData);
                assert(!success);
            } catch {
                /* reverted */
            }

            // post-conditions
            assert(token.balanceOf(address(player)) == playerBalanceBefore);
            assert(token.balanceOf(address(bob)) == bobBalanceBefore);
        }
    }

    function player_approval_should_never_fail(address person, uint256 amount)
        public
    {
        // pre-conditions
        if (person != address(0)) {
            // actions
            try
                player.proxy(
                    address(token),
                    abi.encodeWithSelector(
                        token.approve.selector,
                        person,
                        amount
                    )
                )
            {
                /* success */
            } catch {
                assert(false);
            }

            // post-conditions
            uint256 personAllowanceAfter = token.allowance(
                address(player),
                address(person)
            );
            assert(personAllowanceAfter == amount);
        }
    }

    function transfer_from_should_fail_before_timelock_period(uint256 amount)
        public
    {
        amount = _between(amount, 1, token.INITIAL_SUPPLY());

        // pre-conditions
        uint256 currentTime = block.timestamp;
        uint256 playerBalanceBefore = token.balanceOf(address(player));
        uint256 bobBalanceBefore = token.balanceOf(address(bob));

        // we can set the allowance with the previous property
        // player_approval_should_never_fail(address(bob), amount);

        if (currentTime < token.timeLock()) {
            // action
            try
                player.proxy(
                    address(token),
                    abi.encodeWithSelector(
                        token.transferFrom.selector,
                        address(player),
                        address(bob),
                        amount
                    )
                )
            returns (bool success, bytes memory returnData) {
                emit Log(returnData);
                if (success) {
                    emit AssertionFailed(amount);
                }
            } catch {
                /* reverted */
            }

            // post-conditions
            assert(token.balanceOf(address(player)) == playerBalanceBefore);
            assert(token.balanceOf(address(bob)) == bobBalanceBefore);
        }
    }

    function test_no_free_tokens_in_transfer_from(uint256 amount) public {
        // pre-conditions
        uint256 playerBalanceBefore = token.balanceOf(address(player));
        uint256 bobBalanceBefore = token.balanceOf(address(bob));

        // actions
        try
            player.proxy(
                address(token),
                abi.encodeWithSelector(
                    token.transferFrom.selector,
                    address(player),
                    address(bob),
                    amount
                )
            )
        returns (bool success, bytes memory returnData) {
            emit Log(returnData);
            require(success);
        } catch {}

        // post-conditions
        uint256 playerBalanceAfter = token.balanceOf(address(player));
        uint256 bobBalanceAfter = token.balanceOf(address(bob));
        assert(playerBalanceAfter == playerBalanceBefore - amount);
        assert(bobBalanceAfter == bobBalanceBefore + amount);
    }
}
