pragma solidity ^0.4.26;

/*
 * This is a distributed lottery that chooses random addresses as lucky addresses. If these
 * participate, they get the jackpot: 7 times the price of their bet.
 * Of course one address can only win once. The owner regularly reseeds the secret
 * seed of the contract (based on which the lucky addresses are chosen), so if you did not win,
 * just wait for a reseed and try again!
 *
 * Jackpot chance:   1 in 8
 * Ticket price: Anything larger than (or equal to) 0.1 ETH
 * Jackpot size: 7 times the ticket price
 *
 * HOW TO PARTICIPATE: Just send any amount greater than (or equal to) 0.1 ETH to the contract's address
 * Keep in mind that your address can only win once
 *
 * If the contract doesn't have enough ETH to pay the jackpot, it sends the whole balance.
*/

contract OpenAddressLottery{
    struct SeedComponents{
        uint component1;
        uint component2;
        uint component3;
        uint component4;
    }

    address public owner; // address of the owner
    uint private secretSeed; // seed used to calculate number of an address
    uint private lastReseed; // last reseed - used to automatically reseed the contract every 1000 blocks
    uint public luckyNumber = 7; // if the number of an address equals 7, it wins

    mapping (address => bool) public winner; // keeping track of addresses that have already won

    function OpenAddressLottery() {
        owner = msg.sender;
        reseed(SeedComponents(
            (uint)(block.coinbase),
            block.difficulty,
            block.gaslimit,
            block.timestamp // solhint-disable-line not-rely-on-time
        ));
    }

    function participate() public payable {
        if (msg.value<0.1 ether) return; //verify ticket price
        // make sure he hasn't won already
        require(winner[msg.sender] == false, "Already won");
        if (luckyNumberOfAddress(msg.sender) == luckyNumber) { //check if it equals 7
            winner[msg.sender] = true; // every address can only win once
            uint win=msg.value*7; //win = 7 times the ticket price
            //if the balance isnt sufficient, send everything we've got
            if (win>this.balance) win=this.balance;
            msg.sender.transfer(win);
        }
        if (block.number-lastReseed>1000) {
            //generate a quality random seed
            reseed(SeedComponents(
                (uint)(block.coinbase),
                block.difficulty,
                block.gaslimit,
                block.timestamp // solhint-disable-line not-rely-on-time
            ));
        }
    }

    function luckyNumberOfAddress(address addr) public constant returns(uint n){
        // calculate the number of current address - 1 in 8 chance
        n = uint(keccak256(uint(addr), secretSeed)[0]) % 8;
    }

    function reseed(SeedComponents components) internal {
        secretSeed = uint256(keccak256(
            components.component1,
            components.component2,
            components.component3,
            components.component4
        )); //hash the incoming parameters and use the hash to (re)initialize the seed
        lastReseed = block.number;
    }

    function kill() public {
        require(msg.sender==owner, "Permission denied");
        selfdestruct(msg.sender);
    }

    function forceReseed() public { // reseed initiated by the owner - for testing purposes
        require(msg.sender == owner, "Permission denied");
        SeedComponents s;
        s.component1 = uint(msg.sender);
        s.component2 = uint256(
            block.blockhash(block.number - 1) // solhint-disable-line not-rely-on-block-hash
        );
        s.component3 = block.difficulty*(uint)(block.coinbase);
        s.component4 = tx.gasprice * 7;
        reseed(s); //reseed
    }

    // if someone sends money without any function call, just assume he wanted to participate
    receive() public payable {
        // owner can't participate, he can only fund the jackpot
        if (msg.value >= 0.1 ether && msg.sender != owner) {
            participate();
        }
    }

}
