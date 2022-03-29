pragma solidity ^0.8.0;
import "./MockERC20Permit.sol";

interface iHevm {
    //signs digest with private key sk
    function sign(uint256 sk, bytes32 digest)
        external
        returns (
            uint8 v,
            bytes32 r,
            bytes32 s
        );
}

contract TestDepositWithPermit {
    MockERC20Permit asset;
    iHevm hevm;
    event AssertionFailed(string reason);
    event LogBalance(uint256 balanceOwner, uint256 balanceCaller);
    address constant OWNER = 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF; //address corresponding to private key 0x2

    constructor() {
        hevm = iHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
        asset = new MockERC20Permit("Permit Token", "PMT", 18);
    }

    //helper method to get signature, signs with private key 2
    function getSignature(
        address owner,
        address spender,
        uint256 assetAmount
    )
        internal
        returns (
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                asset.DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(
                        keccak256(
                            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                        ),
                        owner,
                        spender,
                        assetAmount,
                        asset.nonces(owner),
                        block.timestamp
                    )
                )
            )
        );
        (v, r, s) = hevm.sign(2, digest); //this gives us OWNER's signature
    }

    function testERC20PermitDeposit(uint256 amount) public {
        amount = 1 + (amount % 1000000e18); // we'll only consider transfers of up to 1M tokens
        asset.mint(OWNER, amount);

        uint256 previousOwnerBalance = asset.balanceOf(OWNER);
        uint256 previousCallerBalance = asset.balanceOf(address(this));

        emit LogBalance(previousOwnerBalance, previousCallerBalance);
        (uint8 v, bytes32 r, bytes32 s) = getSignature(
            OWNER,
            address(this),
            amount
        );
        try
            asset.permit(OWNER, address(this), amount, block.timestamp, v, r, s)
        {} catch {
            emit AssertionFailed("signature is invalid");
        }
        try asset.transferFrom(OWNER, address(this), amount) {} catch {
            emit AssertionFailed("transferFrom reverted");
        }
        uint256 currentOwnerBalance = asset.balanceOf(OWNER);
        uint256 currentCallerBalance = asset.balanceOf(address(this));
        emit LogBalance(currentOwnerBalance, currentCallerBalance);
        if (
            currentCallerBalance != previousCallerBalance + amount &&
            currentOwnerBalance != 0
        ) {
            emit AssertionFailed("incorrect amount transferred");
        }
    }
}
