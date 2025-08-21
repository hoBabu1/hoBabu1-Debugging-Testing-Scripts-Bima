//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

// imports for sending token from one chain to another
import {Script, console} from "forge-std/Script.sol";

import {IOAppCore} from "@layerzerolabs/oapp-evm/contracts/oapp/interfaces/IOAppCore.sol";
import {SendParam, OFTReceipt} from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import {MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";

// imports for sending and reciving setup
import {Test, console} from "forge-std/Test.sol";
import {ILayerZeroEndpointV2} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {SetConfigParam} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";
//import {ILayerZeroEndpointV2, SetConfigParam} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {UlnConfig} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
import {ExecutorConfig} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/SendLibBase.sol";
import {DebtToken} from "../../contracts/core/DebtToken.sol";

/**
 * Core -
 * Hemi - 30329
 * Sonic - 30332
 */
contract LayerZeroTestSendRecieve is Test {
    uint256 initialBalance = 100 ether;
    uint256 amountToSend = 5 ether;
    using OptionsBuilder for bytes;
    uint256 hemmiFork;
    uint256 sonicFork;
    uint256 coreFork;
    uint256 plumeFork;
    uint256 ethFork;

    address user1 = makeAddr("user1");

    address USBD = 0x6bedE1c6009a78c222D9BDb7974bb67847fdB68c;
    DebtToken debtToken = DebtToken(USBD);

    function setUp() external {
        hemmiFork = vm.createSelectFork("https://rpc.hemi.network/rpc");
        sonicFork = vm.createSelectFork("https://rpc.ankr.com/sonic_mainnet");
        coreFork = vm.createSelectFork("https://rpc-core.icecreamswap.com");
        plumeFork = vm.createSelectFork("https://phoenix-rpc.plumenetwork.xyz");
        ethFork = vm.createSelectFork(
            "https://eth-mainnet.g.alchemy.com/v2/Key"
        );
    }

    /**
     * Core - 30153
     * Hemi - 30329
     * Sonic - 30332
     * Plume - 30370
     * eth - 30101
     */
    function test_LayerZeroTransfer() public {
        uint32 destId = 30101; // IMPORTANT
        vm.selectFork(plumeFork); // IMPORTANT
        deal(address(debtToken), address(this), initialBalance);
        assertEq(debtToken.balanceOf(address(this)), 100 ether);

        (MessagingFee memory fee, SendParam memory sendParam) = getQuoteFee(
            destId,
            amountToSend,
            plumeFork
        ); // IMPORTANT

        debtToken.approve(address(debtToken), amountToSend);
        debtToken.send{value: fee.nativeFee}(sendParam, fee, msg.sender);

        assertEq(
            debtToken.balanceOf(address(this)),
            initialBalance - amountToSend
        );
    }

    function getQuoteFee(
        uint32 destId,
        uint256 _tokensToSend,
        uint256 currNetwork
    ) public returns (MessagingFee memory, SendParam memory) {
        // Fetching environment variables
        address oftAddress = USBD;
        address toAddress = user1;
        vm.selectFork(currNetwork);
        DebtToken sourceOFT = DebtToken(oftAddress);

        bytes memory _extraOptions = OptionsBuilder
            .newOptions()
            .addExecutorLzReceiveOption(1e18, 0);
        SendParam memory sendParam = SendParam(
            destId, // You can also make this dynamic if needed
            addressToBytes32(toAddress),
            _tokensToSend,
            (_tokensToSend * 9) / 10,
            _extraOptions,
            "",
            ""
        );

        MessagingFee memory fee = sourceOFT.quoteSend(sendParam, false);
        return (fee, sendParam);
    }

    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }
}
