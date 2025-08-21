//SPDX-License-Identifier:MIT

pragma solidity ^0.8.19;
import {PriceFeed} from "../../contracts/core/PriceFeed.sol";
import {Script, console} from "../../lib/forge-std/src/Script.sol";

contract ReadFromPriceFeed is Script {
    function run() external {
        uint256 answer;
        address priceFeed = 0x0d1a956cceF81740BfAF3580A34CDFdA7b576c30;
        address collateralAddress = 0x691F17519E79866b5f1f6963D7Ed860900f8508a;
        vm.startBroadcast();
        answer = PriceFeed(priceFeed).fetchPrice(collateralAddress);
        console.log(int256(answer));
        vm.stopBroadcast();
    }
}
