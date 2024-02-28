//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
library Counters {
    struct Counter{
   uint  _value;
   }
   function current(Counter storage counter) internal view returns(uint){
    return counter._value;
   }

   function increment(Counter storage counter) internal{
    unchecked {
        counter._value+=1;
    }
   }

   function decrement(Counter storage counter) internal{
   unchecked {counter._value-=1;}
   }
}