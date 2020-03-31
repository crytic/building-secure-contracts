contract C {
  address [] addrs;
  function push(address a) public {
    addrs.push(a);
  }
  function pop() public {
    addrs.pop();
  }
  function clear() public{
    addrs.length = 0;
  }
  function check() public{
    for(uint256 i = 0; i < addrs.length; i++)
      for(uint256 j = i+1; j < addrs.length; j++)
	if (addrs[i] == addrs[j])
	  addrs[j] = address(0x0);
  }
  function echidna_test() public returns (bool) {
      return true;
  }
}
