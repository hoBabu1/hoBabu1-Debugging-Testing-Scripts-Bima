// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console2} from "../../lib/forge-std/src/Test.sol";
import {TroveManager} from "../../contracts/core/TroveManager.sol";
import {DebtToken} from "../../contracts/core/DebtToken.sol";
import {MultiCollateralHintHelpers} from "../../contracts/core/helpers/MultiCollateralHintHelpers.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RedeemUSBDTest is Test {
    // Contract interfaces
    TroveManager public troveManager;
    DebtToken public debtToken;
    MultiCollateralHintHelpers public hintHelpers;

    // Constants - Fill these with your actual addresses
    address public constant TROVE_MANAGER_ADDRESS =
        0x55796b02a7650C9fEF78bC2E73De1EF6dA719283;
    address public constant USBD_ADDRESS =
        0x165d03D3Df6443B87b4B7a6268fd13d37C5e3127;
    address public constant HINT_HELPER_ADDRESS =
        0xfbb5dc670379677f1e79BA25e48aC974ad71D76a;

    // Test configuration
    uint256 public constant LST_PRICE = 119272.24 ether; // LST price in wei format
    uint256 public constant DEBT_AMOUNT = 80 ether; // Amount to redeem in wei format
    address public userAddress; // Will be set to msg.sender

    function setUp() public {
        // Connect to deployed contracts
        troveManager = TroveManager(TROVE_MANAGER_ADDRESS);
        debtToken = DebtToken(USBD_ADDRESS);
        hintHelpers = MultiCollateralHintHelpers(HINT_HELPER_ADDRESS);

        // Set user address to the specific address provided
        userAddress = 0x39d2770AbcC456f6C6be820705eD966592E0ad96;

        // Get RPC URL and API key for the network
        string memory RPC_URL = vm.envString("BITLAYER_TESTNET_RPC_URL");

        // Fork from Bitlayer testnet
        vm.createSelectFork(RPC_URL);

        // Impersonate the user address
        vm.startPrank(userAddress);

        // Print connected addresses for verification
        console2.log("TroveManager address:", address(troveManager));
        console2.log("DebtToken address:", address(debtToken));
        console2.log("HintHelpers address:", address(hintHelpers));
        console2.log("Impersonating user:", userAddress);
    }

    function testRedeemUSBD() public {
        // Log starting balances
        console2.log("Starting test with LST price:", LST_PRICE / 1e18);
        console2.log("Amount to redeem:", DEBT_AMOUNT / 1e18, "USBD");
        console2.log("User address:", userAddress);

        uint256 initialBalance = debtToken.balanceOf(userAddress);
        console2.log("Initial USBD balance:", initialBalance / 1e18);

        // Check if user has deposited amount (stake in trove)
        uint256 depositedAmount = troveManager.getTroveStake(userAddress);
        console2.log("Deposited amount in trove:", depositedAmount / 1e18);

        // Ensure we have enough USBD tokens
        if (debtToken.balanceOf(userAddress) < DEBT_AMOUNT) {
            console2.log(
                "Insufficient USBD balance. Current:",
                debtToken.balanceOf(userAddress) / 1e18
            );
            console2.log("Needed:", DEBT_AMOUNT / 1e18);
            return;
        }

        // Note: No approval needed - redeemCollateral burns tokens directly from caller

        if (depositedAmount > 0) {
            // User has stake in trove - proceed with direct redemption
            console2.log(
                "User has stake in trove, proceeding with direct redemption..."
            );

            try
                hintHelpers.getRedemptionHints(
                    troveManager, // Pass the contract, not address
                    DEBT_AMOUNT,
                    LST_PRICE,
                    0
                )
            returns (
                address firstRedemptionHint,
                uint256 partialRedemptionHintNICR,
                uint256 truncatedUSBDamount
            ) {
                console2.log(
                    "Redemption hints - FirstRedemptionHint:",
                    firstRedemptionHint
                );
                console2.log(
                    "Redemption hints - PartialRedemptionHintNICR:",
                    partialRedemptionHintNICR
                );
                console2.log(
                    "Truncated USBD amount:",
                    truncatedUSBDamount / 1e18
                );

                // Execute redemption
                try
                    troveManager.redeemCollateral(
                        DEBT_AMOUNT,
                        firstRedemptionHint,
                        address(0), // upperPartialRedemptionHint
                        address(0), // lowerPartialRedemptionHint
                        partialRedemptionHintNICR,
                        0, // maxIterations (0 = unlimited)
                        1 ether // maxFeePercentage (1 ether = 100%)
                    )
                {
                    console2.log("Redemption successful!");

                    // Check final balance
                    uint256 finalBalance = debtToken.balanceOf(userAddress);
                    console2.log("Final USBD balance:", finalBalance / 1e18);
                    console2.log(
                        "USBD redeemed:",
                        (initialBalance - finalBalance) / 1e18
                    );
                } catch Error(string memory reason) {
                    console2.log("Redemption failed with reason:", reason);
                } catch (bytes memory lowLevelData) {
                    console2.log("Redemption failed with low-level error");
                    console2.logBytes(lowLevelData);
                }
            } catch Error(string memory reason) {
                console2.log("GetRedemptionHints failed with reason:", reason);
            } catch (bytes memory lowLevelData) {
                console2.log("GetRedemptionHints failed with low-level error");
                console2.logBytes(lowLevelData);
            }
        } else {
            // User doesn't have stake - handle fee transfer first
            console2.log(
                "User has no stake in trove, handling fee transfer..."
            );

            uint256 feePercentage = 29; // 29% fee
            uint256 feeAmount = (DEBT_AMOUNT * feePercentage) / 100;
            console2.log("Fee amount:", feeAmount / 1e18);

            // Get fee receiver (owner)
            address feeReceiver = troveManager.owner();
            console2.log("Fee receiver address:", feeReceiver);

            // Transfer fee to receiver
            try debtToken.transfer(feeReceiver, feeAmount) {
                console2.log("Fee transfer successful");

                // Calculate remaining debt after fee
                uint256 remainingDebtValue = DEBT_AMOUNT - feeAmount;
                console2.log(
                    "Remaining debt value to redeem:",
                    remainingDebtValue / 1e18
                );

                // Get redemption hints for remaining debt
                try
                    hintHelpers.getRedemptionHints(
                        troveManager, // Pass the contract, not address
                        remainingDebtValue,
                        LST_PRICE,
                        0
                    )
                returns (
                    address firstRedemptionHint,
                    uint256 partialRedemptionHintNICR,
                    uint256 truncatedUSBDamount
                ) {
                    console2.log(
                        "Redemption hints - FirstRedemptionHint:",
                        firstRedemptionHint
                    );
                    console2.log(
                        "Redemption hints - PartialRedemptionHintNICR:",
                        partialRedemptionHintNICR
                    );
                    console2.log(
                        "Truncated USBD amount:",
                        truncatedUSBDamount / 1e18
                    );

                    // Execute redemption for remaining debt
                    try
                        troveManager.redeemCollateral(
                            remainingDebtValue,
                            firstRedemptionHint,
                            address(0), // upperPartialRedemptionHint
                            address(0), // lowerPartialRedemptionHint
                            partialRedemptionHintNICR,
                            0, // maxIterations (0 = unlimited)
                            1 ether // maxFeePercentage (1 ether = 100%)
                        )
                    {
                        console2.log("Redemption successful!");

                        // Check final balance
                        uint256 finalBalance = debtToken.balanceOf(userAddress);
                        console2.log(
                            "Final USBD balance:",
                            finalBalance / 1e18
                        );
                        console2.log(
                            "USBD redeemed:",
                            (initialBalance - finalBalance) / 1e18
                        );
                    } catch Error(string memory reason) {
                        console2.log("Redemption failed with reason:", reason);
                    } catch (bytes memory lowLevelData) {
                        console2.log("Redemption failed with low-level error");
                        console2.logBytes(lowLevelData);
                    }
                } catch Error(string memory reason) {
                    console2.log(
                        "GetRedemptionHints failed with reason:",
                        reason
                    );
                } catch (bytes memory lowLevelData) {
                    console2.log(
                        "GetRedemptionHints failed with low-level error"
                    );
                    console2.logBytes(lowLevelData);
                }
            } catch Error(string memory reason) {
                console2.log("Fee transfer failed with reason:", reason);
            } catch (bytes memory lowLevelData) {
                console2.log("Fee transfer failed with low-level error");
                console2.logBytes(lowLevelData);
            }
        }
    }
}
