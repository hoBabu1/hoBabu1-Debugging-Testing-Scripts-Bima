//SPDX_License-Identifier:MIT

pragma solidity 0.8.19;

import {Script, console} from "lib/forge-std/src/Script.sol";
import {BimaWrappedCollateralFactory} from "../../contracts/wrappers/BimaWrappedCollateralFactory.sol";

contract DeployBimaWrappedCollateralFactory is Script {
    address public bimaCore = 0x0B446824fc53b7898DCcAE72743Ac4c1AD3c2Af7; // ! IMPORTANT
    BimaWrappedCollateralFactory public warppedfactory;

    function run() external {
        vm.startBroadcast();
        warppedfactory = new BimaWrappedCollateralFactory(bimaCore);
        vm.stopBroadcast();
        console.log(
            "Bima Wrapped Collateral Factory Address :",
            address(warppedfactory)
        );
    }
}
