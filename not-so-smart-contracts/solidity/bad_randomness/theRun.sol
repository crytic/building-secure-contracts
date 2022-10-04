pragma solidity ^0.8.17;

contract TheRun {
    // solhint-disable-next-line not-rely-on-time
    uint256 constant private SALT =  block.timestamp;

    address private admin;
    uint private balance = 0;
    uint private payoutId = 0;
    uint private lastPayout = 0;
    uint private winningPot = 0;
    uint private minMultiplier = 1100; //110%

    //Fees are necessary and set very low, the fees will decrease each time they are collected.
    //Fees are just here to maintain the website at beginning, and will progressively go to 0% :)
    uint private fees = 0;
    uint private feeFrac = 20; //Fraction for fees in per"thousand", not percent, so 20 is 2%

    uint private potFrac = 30; //For the winningPot ,30=> 3% are collected. This is fixed.

    constructor() {
        admin = msg.sender;
    }

    modifier onlyowner {if (msg.sender == admin) _;  }

    struct Player {
        address addr;
        uint payout;
        bool paid;
    }

    Player[] private players;

    //--Fallback function
    fallback() payable {
        init();
    }

    //--initiated function
    function init() private {
        uint deposit = msg.value;
        if (msg.value < 500 finney) { // only participation with >1 ether accepted
            msg.sender.transfer(msg.value);
            return;
        }
        if (msg.value > 20 ether) { //only participation with <20 ether accepted
            msg.sender.transfer(msg.value - (20 ether));
            deposit=20 ether;
        }
        participate(deposit);
    }

    //------- Core of the game----------
    function participate(uint deposit) private {
            //calculate the multiplier to apply to the future payout

            uint totalMultiplier = minMultiplier; //initiate totalMultiplier
            if (balance < 1 ether && players.length > 1) {
                totalMultiplier += 100; // + 10 %
            }
            if ((players.length % 10) == 0 && players.length > 1) { //Every 10th participant gets a 10% bonus
                totalMultiplier += 100; // + 10 %
            }

            //add new player in the queue !
            players.push(Player(msg.sender, (deposit * totalMultiplier) / 1000, false));

            //--- UPDATING CONTRACT STATS ----
            winningPot += (deposit * potFrac) / 1000; // take some 3% to add for the winning pot !
            fees += (deposit * feeFrac) / 1000; // collect maintenance fees 2%
            balance += (deposit * (1000 - ( feeFrac + potFrac ))) / 1000; // update balance

            //Classic payout for the participants
            while (balance > players[payoutId].payout) {
                lastPayout = players[payoutId].payout;
                balance -= players[payoutId].payout; // update the balance
                players[payoutId].paid=true;
                players[payoutId].addr.transfer(lastPayout); // pay the man
                // solhint-disable-next-line reentrancy
                payoutId += 1;
            }

            // Winning the Pot :) Condition : paying at least 1 people with deposit > 2 ether and having luck !
            if (( deposit > 1 ether ) && (deposit > players[payoutId].payout)) {
                uint roll = random(100); // take a random number between 1 & 100
                if (roll % 10 == 0 ) { // if lucky : Chances : 1 out of 10 !
                    // solhint-disable-next-line reentrancy
                    winningPot = 0;
                    msg.sender.transfer(winningPot); // Bravo !
                }
            }

    }

    function random(uint max) private constant returns (uint256 result) {
        //get the best seed for randomness
        uint256 x = SALT * 100 / max;
        uint256 y = SALT * block.number / (SALT % 5) ;
        uint256 seed = block.number/3 + (SALT % 300) + lastPayout +y;
        // solhint-disable-next-line not-rely-on-block-hash
        uint256 h = uint256(block.blockhash(seed));
        return uint256((h / x)) % max + 1; //random number between 1 and max
    }

    //---Contract management functions
    function changeOwnership(address _owner) external onlyowner {
        admin = _owner;
    }
    function watchBalance() external constant returns(uint totalBalance) {
        totalBalance = balance /  1 wei;
    }

    function watchBalanceInEther() external constant returns(uint totalBalanceInEther) {
        totalBalanceInEther = balance /  1 ether;
    }

    //Fee functions for creator
    function collectAllFees() external onlyowner {
        require(fees == 0, "No fees to collect");
        feeFrac -= 1;
        fees = 0;
        admin.transfer(fees);
    }

    function getAndReduceFeesByFraction(uint p) external onlyowner {
        if (fees == 0) feeFrac -= 1; // reduce fees.
        fees -= fees / 1000 * p;
        admin.transfer(fees / 1000 * p); // send a percent of fees
    }


    //---Contract informations
    function nextPayout() external constant returns(uint next) {
      next = players[payoutId].payout /  1 wei;
    }

    function watchFees() external constant returns(uint collectedFees) {
      collectedFees = fees / 1 wei;
    }

    function watchWinningPot() external constant returns(uint winningPot) {
      winningPot = winningPot / 1 wei;
    }

    function watchLastPayout() external constant returns(uint payout) {
      payout = lastPayout;
    }

    function totalOfPlayers() external constant returns(uint numberOfPlayers) {
      numberOfPlayers = players.length;
    }

    function playerInfo(uint id) external constant returns(address player, uint payout, bool userPaid) {
      if (id <= players.length) {
          player = players[id].addr;
          payout = players[id].payout / 1 wei;
          userPaid=players[id].paid;
      }
    }

    function payoutQueueSize() external constant returns(uint queueSize) {
      queueSize = players.length - payoutId;
    }

}
