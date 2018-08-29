// A chain-game contract that maintains a 'throne' which agents may pay to rule.
// See www.kingoftheether.com & https://github.com/kieranelby/KingOfTheEtherThrone .
// (c) Kieran Elby 2016. All rights reserved.
// v0.4.0.
// Inspired by ethereumpyramid.com and the (now-gone?) "magnificent bitcoin gem".

// This contract lives on the blockchain at 0xb336a86e2feb1e87a328fcb7dd4d04de3df254d0
// and was compiled (using optimization) with:
// Solidity version: 0.2.1-fad2d4df/.-Emscripten/clang/int linked to libethereum

// For future versions it would be nice to ...
// TODO - enforce time-limit on reign (can contracts do that without external action)?
// TODO - add a random reset?
// TODO - add bitcoin bridge so agents can pay in bitcoin?
// TODO - maybe allow different return payment address?
pragma solidity ^0.4.19;

contract KingOfTheEtherThrone {

    struct Monarch {
        // Address to which their compensation will be sent.
        address etherAddress;
        // A name by which they wish to be known.
        // NB: Unfortunately "string" seems to expose some bugs in web3.
        string name;
        // How much did they pay to become monarch?
        uint claimPrice;
        // When did their rule start (based on block.timestamp)?
        uint coronationTimestamp;
    }

    // The wizard is the hidden power behind the throne; they
    // occupy the throne during gaps in succession and collect fees.
    address wizardAddress;

    // Used to ensure only the wizard can do some things.
    modifier onlywizard { if (msg.sender == wizardAddress) _; }

    // How much must the first monarch pay?
    uint constant startingClaimPrice = 100 finney;

    // The next claimPrice is calculated from the previous claimFee
    // by multiplying by claimFeeAdjustNum and dividing by claimFeeAdjustDen -
    // for example, num=3 and den=2 would cause a 50% increase.
    uint constant claimPriceAdjustNum = 3;
    uint constant claimPriceAdjustDen = 2;

    // How much of each claimFee goes to the wizard (expressed as a fraction)?
    // e.g. num=1 and den=100 would deduct 1% for the wizard, leaving 99% as
    // the compensation fee for the usurped monarch.
    uint constant wizardCommissionFractionNum = 1;
    uint constant wizardCommissionFractionDen = 100;

    // How much must an agent pay now to become the monarch?
    uint public currentClaimPrice;

    // The King (or Queen) of the Ether.
    Monarch public currentMonarch;

    // Earliest-first list of previous throne holders.
    Monarch[] public pastMonarchs;

    // Create a new throne, with the creator as wizard and first ruler.
    // Sets up some hopefully sensible defaults.
    function KingOfTheEtherThrone() {
        wizardAddress = msg.sender;
        currentClaimPrice = startingClaimPrice;
        currentMonarch = Monarch(
            wizardAddress,
            "[Vacant]",
            0,
            block.timestamp
        );
    }

    function numberOfMonarchs() constant returns (uint n) {
        return pastMonarchs.length;
    }

    // Fired when the throne is claimed.
    // In theory can be used to help build a front-end.
    event ThroneClaimed(
        address usurperEtherAddress,
        string usurperName,
        uint newClaimPrice
    );

    // Fallback function - simple transactions trigger this.
    // Assume the message data is their desired name.
    function() {
        claimThrone(string(msg.data));
    }

    // Claim the throne for the given name by paying the currentClaimFee.
    function claimThrone(string name) {

        uint valuePaid = msg.value;

        // If they paid too little, reject claim and refund their money.
        if (valuePaid < currentClaimPrice) {
            msg.sender.send(valuePaid);
            return;
        }

        // If they paid too much, continue with claim but refund the excess.
        if (valuePaid > currentClaimPrice) {
            uint excessPaid = valuePaid - currentClaimPrice;
            msg.sender.send(excessPaid);
            valuePaid = valuePaid - excessPaid;
        }

        // The claim price payment goes to the current monarch as compensation
        // (with a commission held back for the wizard). We let the wizard's
        // payments accumulate to avoid wasting gas sending small fees.

        uint wizardCommission = (valuePaid * wizardCommissionFractionNum) / wizardCommissionFractionDen;

        uint compensation = valuePaid - wizardCommission;

        if (currentMonarch.etherAddress != wizardAddress) {
            currentMonarch.etherAddress.send(compensation);
        } else {
            // When the throne is vacant, the fee accumulates for the wizard.
        }

        // Usurp the current monarch, replacing them with the new one.
        pastMonarchs.push(currentMonarch);
        currentMonarch = Monarch(
            msg.sender,
            name,
            valuePaid,
            block.timestamp
        );

        // Increase the claim fee for next time.
        // Stop number of trailing decimals getting silly - we round it a bit.
        uint rawNewClaimPrice = currentClaimPrice * claimPriceAdjustNum / claimPriceAdjustDen;
        if (rawNewClaimPrice < 10 finney) {
            currentClaimPrice = rawNewClaimPrice;
        } else if (rawNewClaimPrice < 100 finney) {
            currentClaimPrice = 100 szabo * (rawNewClaimPrice / 100 szabo);
        } else if (rawNewClaimPrice < 1 ether) {
            currentClaimPrice = 1 finney * (rawNewClaimPrice / 1 finney);
        } else if (rawNewClaimPrice < 10 ether) {
            currentClaimPrice = 10 finney * (rawNewClaimPrice / 10 finney);
        } else if (rawNewClaimPrice < 100 ether) {
            currentClaimPrice = 100 finney * (rawNewClaimPrice / 100 finney);
        } else if (rawNewClaimPrice < 1000 ether) {
            currentClaimPrice = 1 ether * (rawNewClaimPrice / 1 ether);
        } else if (rawNewClaimPrice < 10000 ether) {
            currentClaimPrice = 10 ether * (rawNewClaimPrice / 10 ether);
        } else {
            currentClaimPrice = rawNewClaimPrice;
        }

        // Hail the new monarch!
        ThroneClaimed(currentMonarch.etherAddress, currentMonarch.name, currentClaimPrice);
    }

    // Used only by the wizard to collect his commission.
    function sweepCommission(uint amount) onlywizard {
        wizardAddress.send(amount);
    }

    // Used only by the wizard to collect his commission.
    function transferOwnership(address newOwner) onlywizard {
        wizardAddress = newOwner;
    }

}
