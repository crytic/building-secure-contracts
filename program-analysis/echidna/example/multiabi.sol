pragma solidity ^0.8.0;

contract Flag {

   bool flag = false;

   function flip() public {
       flag = !flag;
   }

   function get() public returns (bool) {
        return flag;
   }

   function test_fail() public {
       assert(false);
   }
}


contract EchidnaTest {
   Flag f;

   constructor() {
      f = new Flag();
   }

   function test_flag_is_false() public {
      assert(f.get() == false);
   }

}