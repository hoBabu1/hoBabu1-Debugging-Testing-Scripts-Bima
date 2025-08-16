// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";

// contracts

import {StakedUsbdOft} from "../StakedUsbdOft.sol";
import {StakedUsbdOftAdapter} from "../StakedUsbdOftAdapter.sol";

contract WiringOfOfts is Script {
    address stakedUsbdOft = 0x9a64371655872B16395342B0C7A27C16d9eaC78e;
    address stakedUsbdOftadapter = 0x5EB75a7DC200dE696FF64E57fD54f4f3060b286f;

    uint32 SOURCE_CHAIN_E_ID = 40217;
    uint32 DESTINATION_CHAIN_E_ID = 40267;

    function run() external {
        vm.startBroadcast();
        // // Will be deployed on destination chain
        // StakedUsbdOft(stakedUsbdOft).setPeer(SOURCE_CHAIN_E_ID,addressToBytes32(stakedUsbdOftadapter));
        // Will be deployed on source chain
        StakedUsbdOftAdapter(stakedUsbdOftadapter).setPeer(
            DESTINATION_CHAIN_E_ID,
            addressToBytes32(address(stakedUsbdOft))
        );
        vm.stopBroadcast();
    }

    function addressToBytes32(address _addr) public pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }
}
