contract C {
  uint state;
  function expensive(uint8 times) internal {
    for(uint8 i = 0; i < times; i++)
      state = state + i;
  }
  function f(uint x, uint y, uint8 times) public {
    if (x == 42 && y == 123)
      expensive(times);
    else
      state = 0;
  }
  function echidna_test() public returns (bool) {
    return true;
  }
}
