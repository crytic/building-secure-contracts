contract Suicidal {
  address owner;
  function suicide() public returns (address) {
    require(owner == msg.sender);
    selfdestruct(owner);
  }
}
contract C is Suicidal {
  address owner;
  function C() {
    owner = msg.sender;
  }
}
