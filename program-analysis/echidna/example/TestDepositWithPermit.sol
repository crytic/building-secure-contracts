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
    address[] callers;

    constructor() {
        hevm = iHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
        asset = new MockERC20Permit("Permit Token", "PMT", 18);
    }

    //helper method to get signature, signs with private key 1
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
        (v, r, s) = hevm.sign(1, digest); //this gives us address 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf - which we set as this contract's address in config
    }

    function testERC20PermitDeposit(uint256 amount) public {
        asset.mint(address(this), amount);

        uint256 previousOwnerBalance = asset.balanceOf(address(this));
        uint256 previousCallerBalance = asset.balanceOf(msg.sender);

        emit LogBalance(previousOwnerBalance, previousCallerBalance);
        (uint8 v, bytes32 r, bytes32 s) = getSignature(
            address(this),
            address(this),
            amount
        );
        asset.permit(
            address(this),
            address(this),
            amount,
            block.timestamp,
            v,
            r,
            s
        );
        asset.transferFrom(address(this), msg.sender, amount);
        uint256 currentOwnerBalance = asset.balanceOf(address(this));
        uint256 currentCallerBalance = asset.balanceOf(msg.sender);
        emit LogBalance(currentOwnerBalance, currentCallerBalance);
        if (currentCallerBalance != previousCallerBalance + amount) {
            emit AssertionFailed("did not successfully transfer assets");
        }
    }
}
