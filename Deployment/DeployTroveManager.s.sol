// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console} from "../../lib/forge-std/src/Script.sol";

import {PriceFeed} from "../../contracts/core/PriceFeed.sol";
import {Factory} from "../../contracts/core/Factory.sol";
import {BimaVault} from "../../contracts/dao/Vault.sol";
import {IFactory} from "../../contracts/interfaces/IFactory.sol";

contract DeployTroveManager is Script {
    // Contract Addresses
    address constant COLLATERAL_ADDRESS =
        0x756121da5326a9963ddAb75575c751B0CeB46362;
    address constant FACTORY_ADDRESS =
        0xb1dF28E9ca204ad8fe4EA2605e1efd13Bbf3d145;
    address constant PRICEFEED_ADDRESS =
        0x3ebC5c1dF3EE95f92dF86094c32F293F15998016;
    address constant BIMAVAULT_ADDRESS =
        0x5A3c9c955d6909574756C96F80f10F6BD603b073;
    address constant ORACLE_ADDRESS =
        0xf711d342630cB0649e4D07d458B8a3c4750bE32f;

    // PriceFeed config for the Oracle
    uint32 constant ORACLE_HEARBEAT = 3600;
    bytes4 constant SHARE_PRICE_SIGNATURE = 0x00000000;
    uint8 constant SHARE_PRICE_DECIMALS = 18;
    bool constant IS_BASE_CURRENCY_ETH_INDEXED = false;

    // TroveManager config
    address constant CUSTOM_TROVE_MANAGER_IMPL_ADDRESS = address(0);
    address constant CUSTOM_SORTED_TROVES_IMPL_ADDRESS = address(0);

    uint256 constant MINUTE_DECAY_FACTOR = 999037758833783000;
    uint256 constant REDEMPTION_FEE_FLOOR = 0.005 ether;
    uint256 constant MAX_REDEMPTION_FEE = 1 ether;
    uint256 constant BORROWING_FEE_FLOOR = 0.01 ether;
    uint256 constant MAX_BORROWING_FEE = 0.03 ether;
    uint256 constant INTEREST_RATE_IN_BPS = 0;
    uint256 constant MAX_DEBT = 10000000000 ether;
    uint256 constant MCR = 1.5 ether;

    // Receiver
    uint256 constant REGISTERED_RECEIVER_COUNT = 2;

    function run() external {
        vm.startBroadcast();
        PriceFeed priceFeed = PriceFeed(PRICEFEED_ADDRESS);
        Factory factory = Factory(FACTORY_ADDRESS);
        BimaVault bimaVault = BimaVault(BIMAVAULT_ADDRESS);
        console.log("troveManagerCount before: ", factory.troveManagerCount());

        //Set Oracle on PriceFeed contract
        priceFeed.setOracle(
            COLLATERAL_ADDRESS,
            ORACLE_ADDRESS,
            ORACLE_HEARBEAT,
            SHARE_PRICE_SIGNATURE,
            SHARE_PRICE_DECIMALS,
            IS_BASE_CURRENCY_ETH_INDEXED
        );
        console.log("Oracle is set on PriceFeed contract!");

        // Deploy New Trove Manager instance
        factory.deployNewInstance(
            COLLATERAL_ADDRESS,
            PRICEFEED_ADDRESS,
            CUSTOM_TROVE_MANAGER_IMPL_ADDRESS,
            CUSTOM_SORTED_TROVES_IMPL_ADDRESS,
            IFactory.DeploymentParams({
                minuteDecayFactor: 999037758833783000,
                redemptionFeeFloor: (1e18 / 1000) * 5,
                maxRedemptionFee: 1e18,
                borrowingFeeFloor: (1e18 / 1000) * 5,
                maxBorrowingFee: (1e18 / 100) * 5,
                interestRateInBps: 100,
                maxDebt: MAX_DEBT, // Replace with actual maxDebt value
                MCR: 12 * 1e17
            })
        );
        console.log("New Trove Manager is deployed from Factory contract!");

        uint256 troveManagerCount = factory.troveManagerCount();
        //console.log("troveManagerCount after: ", troveManagerCount);

        address troveManagerAddressFromFactory = factory.troveManagers(
            troveManagerCount - 1
        );

        // Register Receiver
        bimaVault.registerReceiver(
            troveManagerAddressFromFactory,
            REGISTERED_RECEIVER_COUNT
        );
        console.log("Receiver has been registered!");

        console.log(
            "new Trove Manager address: ",
            troveManagerAddressFromFactory
        );

        vm.stopBroadcast();
    }
}
