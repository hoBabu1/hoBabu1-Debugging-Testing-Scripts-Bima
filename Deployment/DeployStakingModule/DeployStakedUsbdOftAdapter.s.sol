// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";

// contracts
import {StakingModule} from "../StakingModule.sol";
import {StakedUsbdOftAdapter} from "../StakedUsbdOftAdapter.sol";

contract DeployStakedUsbdOftAdapter is Script {
    // STEP 2
    address public sUSBD_ADDRESS = 0xe6eb0A93Cf1309811C889686d8F32e3Bf80E6Ae6; // !! IMPORTANT
    address public STAKING_MODULE = 0x360EB20e8Dd0c8d08506b9da4Af44Df8b0D405aE; //! IMPORTANT

    StakedUsbdOftAdapter stakedUsbdOftadapter;
    address lzEndpointV2 = 0x6EDCE65403992e310A62460808c4b910D972f10f;

    function run() external {
        vm.startBroadcast();
        stakedUsbdOftadapter = new StakedUsbdOftAdapter(
            sUSBD_ADDRESS,
            STAKING_MODULE,
            lzEndpointV2,
            msg.sender
        );
        vm.stopBroadcast();
        console.log(
            "Address of Staked Usbd Oft Adapter ",
            address(stakedUsbdOftadapter)
        );
    }
}
