//SPDX-License-Identifier:MIT

pragma solidity ^0.8.19;
import {IAggregatorV3Interface} from "../../contracts/interfaces/IAggregatorV3Interface.sol";
import {Script, console} from "../../lib/forge-std/src/Script.sol";

contract readFromOracle is Script {
    function run() external {
        uint80 roundId;
        int256 answer;
        uint256 startedAt;
        uint256 updatedAt;
        uint80 answeredInRound;
        IAggregatorV3Interface newFeed = IAggregatorV3Interface(
            0xf711d342630cB0649e4D07d458B8a3c4750bE32f
        );
        vm.startBroadcast();
        (roundId, answer, startedAt, updatedAt, answeredInRound) = newFeed
            .latestRoundData();
        console.log("answer", answer);
        vm.stopBroadcast();
    }
}
