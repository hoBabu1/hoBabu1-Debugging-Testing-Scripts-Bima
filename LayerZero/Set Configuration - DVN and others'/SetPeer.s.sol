// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Script, console} from "forge-std/Script.sol";

// contracts
import {DebtToken} from "../contracts/core/DebtToken.sol";

contract setPeer is Script {
    // holesky
    address SOURCE_CHAIN_OFT_ADDRESS =
        0xF7c54926C287350DBbb9460e5859B94dFDe087Fa; //IMPORTANT
    uint32 SOURCE_CHAIN_E_ID = 40217; //IMPORTANT

    // core
    address DESTINATION_CHAIN_OFT_ADDRESS =
        0x983f1e977D0aB7DAd0D7Bfa2A78fc7ADFC75fa64; //!IMPORTANT
    uint32 DESTINATION_CHAIN_E_ID = 40153; //IMPORTANT

    function run() external {
        vm.startBroadcast();

        // DebtToken(SOURCE_CHAIN_OFT_ADDRESS).setPeer(
        //     DESTINATION_CHAIN_E_ID,
        //     addressToBytes32(DESTINATION_CHAIN_OFT_ADDRESS)
        // );
        // console.log("Peer set");

        DebtToken(DESTINATION_CHAIN_OFT_ADDRESS).setPeer(
            SOURCE_CHAIN_E_ID,
            addressToBytes32(SOURCE_CHAIN_OFT_ADDRESS)
        );
        console.log("Peer set");

        vm.stopBroadcast();
    }

    function addressToBytes32(address _addr) public pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }
}
