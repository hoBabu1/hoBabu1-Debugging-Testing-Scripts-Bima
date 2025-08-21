// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { Script, console } from "forge-std/Script.sol";

// contracts
import { StakingModule } from "../StakingModule.sol";
import { StakedUsbd } from "../StakedUsbd.sol";
contract DeploySusbd is Script  {

    address public  USBD_ADDRESS = ; // !! IMPORTANT
    StakedUsbd public sUsbd;
    StakingModule public stakingModule;
    function run() external {

        vm.startBroadcast();

        // Deploy StakedUsbd
        sUsbd = new StakedUsbd("Staked US Bitcoin Dollar", "sUSBD", msg.sender);
        console.log("sUSBD Address : ", address(sUsbd));

        // Deploy StakingModule
        stakingModule = new StakingModule(USBD_ADDRESS, address(sUsbd), msg.sender);
        console.log("Staking Module Address : ", address(stakingModule));

        sUsbd.grantRole(sUsbd.MINTER(), address(stakingModule));

        vm.stopBroadcast();
    }
}