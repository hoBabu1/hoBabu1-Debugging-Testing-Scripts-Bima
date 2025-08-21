//SPDX_License-Identifier:MIT

pragma solidity 0.8.19;

import {Script, console} from "lib/forge-std/src/Script.sol";

import {BimaWrappedCollateralFactory} from "../../contracts/wrappers/BimaWrappedCollateralFactory.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {BimaWrappedCollateral} from "../../contracts/wrappers/BimaWrappedCollateral.sol";

contract DeployWarppCollateral is Script {
    // get this address after deploying  `BimaWrappedCollateralFactory`
    address public warppedfactory = 0xC9ed30fE7a18159d3859C2b417D39657c12cE88d; // ! IMPORTANT

    // Collateral , decamila is less than 18
    address public collateralAddress =
        0xfa04bFf86bdE5462a8c5cf79aCc1BB21A3c742b0; // IMPORTANT

    string public collateralName = "w-Bima BTC";
    string public collateralSymbol = "w-BMBTC";
    BimaWrappedCollateral _wrappedColl;

    function run() external {
        vm.startBroadcast();

        // Creating wrapper of Collateral
        BimaWrappedCollateralFactory(warppedfactory).createWrapper(
            collateralAddress,
            collateralName,
            collateralSymbol
        );

        // Get the wrapped Colateral Address
        _wrappedColl = BimaWrappedCollateralFactory(warppedfactory)
            .getWrappedColl(IERC20(collateralAddress));

        vm.stopBroadcast();
        // get the address of wrapped collateral
        console.log("Wrapped Collateral Address :", address(_wrappedColl));
    }
}
