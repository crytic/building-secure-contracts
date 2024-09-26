// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

contract Flag {
    bool flag = false;

    function flip() public {
        flag = !flag;
    }

    function get() public view returns (bool) {
        return flag;
    }

    function test_fail() public pure {
        assert(false);
    }
}

contract EchidnaTest {
    Flag f;

    constructor() {
        f = new Flag();
    }

    function test_flag_is_false() public view {
        assert(f.get() == false);
    }
}
