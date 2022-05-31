contract theRun {
        uint private Balance = 0;
        uint private Payout_id = 0;
        uint private Last_Payout = 0;
        uint private WinningPot = 0;
        uint private Min_multiplier = 1100; //110%
        

        //Fees are necessary and set very low, to maintain the website. The fees will decrease each time they are collected.
        //Fees are just here to maintain the website at beginning, and will progressively go to 0% :)
        uint private fees = 0;
        uint private feeFrac = 20; //Fraction for fees in per"thousand", not percent, so 20 is 2%
        
        uint private PotFrac = 30; //For the WinningPot ,30=> 3% are collected. This is fixed.
        
        
        address private admin;
        
        function theRun() {
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
        function() {
            init();
        }

        //--initiated function
        function init() private {
            uint deposit=msg.value;
            if (msg.value < 500 finney) { //only participation with >1 ether accepted
                    msg.sender.send(msg.value);
                    return;
            }
            if (msg.value > 20 ether) { //only participation with <20 ether accepted
                    msg.sender.send(msg.value- (20 ether));
                    deposit=20 ether;
            }
            Participate(deposit);
        }

        //------- Core of the game----------
        function Participate(uint deposit) private {
                //calculate the multiplier to apply to the future payout
                

                uint total_multiplier=Min_multiplier; //initiate total_multiplier
                if(Balance < 1 ether && players.length>1){
                    total_multiplier+=100; // + 10 %
                }
                if( (players.length % 10)==0 && players.length>1 ){ //Every 10th participant gets a 10% bonus, play smart !
                    total_multiplier+=100; // + 10 %
                }
                
                //add new player in the queue !
                players.push(Player(msg.sender, (deposit * total_multiplier) / 1000, false));
                
                //--- UPDATING CONTRACT STATS ----
                WinningPot += (deposit * PotFrac) / 1000; // take some 3% to add for the winning pot !
                fees += (deposit * feeFrac) / 1000; // collect maintenance fees 2%
                Balance += (deposit * (1000 - ( feeFrac + PotFrac ))) / 1000; // update balance

                // Winning the Pot :) Condition : paying at least 1 people with deposit > 2 ether and having luck !
                if(  ( deposit > 1 ether ) && (deposit > players[Payout_id].payout) ){ 
                    uint roll = random(100); //take a random number between 1 & 100
                    if( roll % 10 == 0 ){ //if lucky : Chances : 1 out of 10 ! 
                        msg.sender.send(WinningPot); // Bravo !
                        WinningPot=0;
                    }
                    
                }
                
                //Classic payout for the participants
                while ( Balance > players[Payout_id].payout ) {
                    Last_Payout = players[Payout_id].payout;
                    players[Payout_id].addr.send(Last_Payout); //pay the man, please !
                    Balance -= players[Payout_id].payout; //update the balance
                    players[Payout_id].paid=true;
                    
                    Payout_id += 1;
                }
        }



    uint256 constant private salt =  block.timestamp;
    
    function random(uint Max) constant private returns (uint256 result){
        //get the best seed for randomness
        uint256 x = salt * 100 / Max;
        uint256 y = salt * block.number / (salt % 5) ;
        uint256 seed = block.number/3 + (salt % 300) + Last_Payout +y; 
        uint256 h = uint256(block.blockhash(seed)); 
    
        return uint256((h / x)) % Max + 1; //random number between 1 and Max
    }
    
    

    //---Contract management functions
    function ChangeOwnership(address _owner) onlyowner {
        admin = _owner;
    }
    function WatchBalance() constant returns(uint TotalBalance) {
        TotalBalance = Balance /  1 wei;
    }
    
    function WatchBalanceInEther() constant returns(uint TotalBalanceInEther) {
        TotalBalanceInEther = Balance /  1 ether;
    }
    
    
    //Fee functions for creator
    function CollectAllFees() onlyowner {
        if (fees == 0) throw;
        admin.send(fees);
        feeFrac-=1;
        fees = 0;
    }
    
    function GetAndReduceFeesByFraction(uint p) onlyowner {
        if (fees == 0) feeFrac-=1; //Reduce fees.
        admin.send(fees / 1000 * p);//send a percent of fees
        fees -= fees / 1000 * p;
    }
        

//---Contract informations
function NextPayout() constant returns(uint NextPayout) {
    NextPayout = players[Payout_id].payout /  1 wei;
}

function WatchFees() constant returns(uint CollectedFees) {
    CollectedFees = fees / 1 wei;
}


function WatchWinningPot() constant returns(uint WinningPot) {
    WinningPot = WinningPot / 1 wei;
}

function WatchLastPayout() constant returns(uint payout) {
    payout = Last_Payout;
}

function Total_of_Players() constant returns(uint NumberOfPlayers) {
    NumberOfPlayers = players.length;
}

function PlayerInfo(uint id) constant returns(address Address, uint Payout, bool UserPaid) {
    if (id <= players.length) {
        Address = players[id].addr;
        Payout = players[id].payout / 1 wei;
        UserPaid=players[id].paid;
    }
}

function PayoutQueueSize() constant returns(uint QueueSize) {
    QueueSize = players.length - Payout_id;
}


}
