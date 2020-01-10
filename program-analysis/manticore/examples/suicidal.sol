contract Suicidal {

  function backdoor() public {
    selfdestruct(msg.sender);
  }

}
