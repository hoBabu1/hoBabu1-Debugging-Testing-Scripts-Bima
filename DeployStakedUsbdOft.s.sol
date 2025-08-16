// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";

// contracts

import {StakedUsbdOft} from "../StakedUsbdOft.sol";

contract DeployStakedUsbdOft is Script {
    StakedUsbdOft stakedUsbdOft;
    address lzEndpointV2 = 0x6EDCE65403992e310A62460808c4b910D972f10f; // !IMPORTANT

    function run() external {
        vm.startBroadcast();
        stakedUsbdOft = new StakedUsbdOft(
            "Staked US Bitcoin Dollar",
            "sUSBD",
            lzEndpointV2,
            msg.sender
        );
        vm.stopBroadcast();

        console.log("Staked USBD Oft Address", address(stakedUsbdOft));
    }
}
