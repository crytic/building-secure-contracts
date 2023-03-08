contract Simple {
    function f(uint256 a) public payable {
        if (a == 65) {
            revert();
        }
    }
}
