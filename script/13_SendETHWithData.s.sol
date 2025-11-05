// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {FootballBetShare} from "../src/FootballBetShare.sol";

// Send ETH with random data through triggers fallback()
// Usage: forge script script/13_SendETHWithData.s.sol:SendETHWithData --rpc-url $RPC_URL --broadcast

contract SendETHWithData is Script {
    function run() external {
        require(vm.envExists("CONTRACT_ADDRESS"), "CONTRACT_ADDRESS not set");
        require(vm.envExists("USER_PRIVATE_KEY"), "USER_PRIVATE_KEY not set");

        address payable contractAddress = payable(
            vm.envAddress("CONTRACT_ADDRESS")
        );
        uint256 userPrivateKey = vm.envUint("USER_PRIVATE_KEY");

        FootballBetShare fbs = FootballBetShare(contractAddress);

        uint256 balanceBefore = address(fbs).balance;
        console.log("Contract balance before:", balanceBefore);

        vm.startBroadcast(userPrivateKey);

        uint256 sendAmount = 3 ether;
        bytes memory randomData = abi.encodeWithSignature(
            "nonExistentFunction()"
        );
        (bool success, ) = payable(address(fbs)).call{value: sendAmount}(
            randomData
        );
        require(success, "Transfer failed");

        vm.stopBroadcast();

        uint256 balanceAfter = address(fbs).balance;
        console.log("Contract balance after:", balanceAfter);
        console.log("Amount sent:", sendAmount);
        console.log("Total funds received:", fbs.totalFundsReceived());
        console.log("\nNote: This triggered the fallback() function");
    }
}
