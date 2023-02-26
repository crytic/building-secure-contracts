# Gas optimization tips:

1. X += Y COSTS MORE GAS THAN X = X + Y FOR STATE VARIABLES 
    - Using the addition operator instead of plus-equals saves 113 gas. 

 

2. ++I COSTS LESS GAS THAN I++, ESPECIALLY WHEN IT’S USED IN FOR-LOOPS (--I/I-- TOO) 
     - Saves 5 gas per loop. 

 

3. instead of using operator && on single require check . using double require check can save more gas: 

        **BAD**: require(amount_ != uint256(0) && amount_ <= MAX_TOTAL_XDEFI_SUPPLY, "INVALID_AMOUNT"); 

        **GOOD**: require(amount_ != uint256(0), "INVALID_AMOUNT" ); 
        require(amount_ <= MAX_TOTAL_XDEFI_SUPPLY, "INVALID_AMOUNT"); 

 

4. USE CUSTOM ERRORS RATHER THAN REVERT()/REQUIRE() STRINGS TO SAVE GAS 

    - Custom errors are available from solidity version 0.8.4. Custom errors save ~50 gas  

 

5. FUNCTIONS GUARANTEED TO REVERT WHEN CALLED BY NORMAL USERS CAN BE MARKED PAYABLE 

    - If a function modifier such as onlyOwner is used, the function will revert if a normal user tries to pay the function. Marking the function as payable will lower the gas cost for legitimate callers because the compiler will not include checks for whether a payment was provided. The extra opcodes avoided are CALLVALUE(2),DUP1(3),ISZERO(3),PUSH2(3),JUMPI(10),PUSH1(3),DUP1(3),REVERT(0),JUMPDEST(1),POP(2), which costs an average of about 21 gas per call to the function, in addition to the extra deployment cost. 