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
		//************************* Action *************************/
		delLiquidity = LiquidityTracker.add_funds(reserve,delRisky,delStable);
		//************************* Post-Conditions *************************/
	}
	function reserve_remove_funds(uint256 delLiquidity) public returns (uint256 removeRisky, uint256 removeStable) {
		//************************* Pre-Conditions *************************/
		//************************* Action *************************/
		(removeRisky, removeStable) = LiquidityTracker.remove_funds(reserve,delLiquidity); // call LiquidityTracker.remove
		//************************* Post-Conditions *************************/
	}

	function add_funds_then_remove_funds(uint delRisky, uint256 delStable) public {
		//************************* Pre-Conditions *************************/
		//************************* Action *************************/
		//************************* Post-Conditions *************************/
	}
	function _between(uint256 random, uint256 low, uint256 high) private returns (uint256) {
		return low + random % (high-low);
	}
}
