//pragma experimental ABIEncoderV2;
pragma solidity 0.8.0;
import "./LiquidityTracker.sol";

contract LibraryMathEchidna { 
	LiquidityTracker.Data private reserve; // (0,0,0,0,0,0,0)
	event LogUint256(string msg, uint256);
	event AssertionFailed(string msg, uint256 expected, uint256 actualValue);
	bool isSetup;
	function setupReserve() private {
		reserve.reserveRisky = 1 ether;
		reserve.reserveStable = 2 ether;
		reserve.liquidity = 3 ether;
		isSetup = true;
	}
	//"safe"-version of reserve_add_funds (1-uint128.max)
	function reserve_add_funds(uint256 delRisky, uint256 delStable) public returns (LiquidityTracker.Data memory preReserve, uint256 delLiquidity){
		//************************* Pre-Conditions *************************/
		//@note PRECONDITION: isSetup has to be true (0,0,...,0)
		if (!isSetup) setupReserve();

		preReserve = reserve;
		
		delLiquidity = LiquidityTracker.add_funds(reserve,delRisky,delStable);

		assert(reserve.reserveRisky == delRisky + preReserve.reserveRisky);
		assert(reserve.reserveStable == delStable + preReserve.reserveStable);

		//************************* Post-Conditions *************************/
	}
	function reserve_remove_funds(uint256 delLiquidity) public returns (uint256 removeRisky, uint256 removeStable) {
		//************************* Pre-Conditions *************************/
		if (!isSetup) {  
			setupReserve(); // set up the liquidity with starting value if it has not been started before
		}
		uint256 oldRisky = reserve.reserveRisky;
		uint256 oldStable = reserve.reserveStable;			
		LiquidityTracker.Data memory preRemoveReserve  = reserve; // save the pre-remove liquidity balances		
		//************************* Action *************************/		
		(removeRisky, removeStable) = LiquidityTracker.remove_funds(reserve,delLiquidity); // call LiquidityTracker.remove

		assert(reserve.reserveRisky == preRemoveReserve.reserveRisky - removeRisky);
		assert(reserve.reserveStable == preRemoveReserve.reserveStable - removeStable);
	}

	function add_funds_then_remove_funds(uint delRisky, uint256 delStable) public {
		//************************* Pre-Conditions *************************/

		//************************* Action *************************/
		(LiquidityTracker.Data memory preAllocateReserve, uint256 delAllocateLiq) = reserve_add_funds(delRisky, delStable);
		(uint256 removeRisky, uint256 removeStable) = reserve_remove_funds(delAllocateLiq);

		//************************* Post-Conditions *************************/
		LiquidityTracker.Data memory postRemoveReserve = reserve;

		assert(preAllocateReserve.reserveRisky == postRemoveReserve.reserveRisky);
		assert(preAllocateReserve.reserveStable == postRemoveReserve.reserveStable);		
		assert(preAllocateReserve.liquidity == postRemoveReserve.liquidity);		
	}
	function _between(uint256 random, uint256 low, uint256 high) private returns (uint256) {
		return low + random % (high-low);
	}
}
