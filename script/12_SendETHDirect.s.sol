// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {FootballBetShare} from "../src/FootballBetShare.sol";

// Send ETH directly through receive()
// Usage: forge script script/12_SendETHDirect.s.sol:SendETHDirect --rpc-url $RPC_URL --broadcast

contract SendETHDirect is Script {
    function run() external {
        require(vm.envExists("CONTRACT_ADDRESS"), "CONTRACT_ADDRESS not set");
        require(vm.envExists("PRIVATE_KEY"), "DEPLOYER_PRIVATE_KEY not set");

        address payable contractAddress = payable(
            vm.envAddress("CONTRACT_ADDRESS")
        );
        uint256 userPrivateKey = vm.envUint("USER_PRIVATE_KEY");

        FootballBetShare fbs = FootballBetShare(contractAddress);

        uint256 balanceBefore = address(fbs).balance;
        console.log("Contract balance before:", balanceBefore);

        vm.startBroadcast(userPrivateKey);

        uint256 sendAmount = 5 ether;
        (bool success, ) = payable(address(fbs)).call{value: sendAmount}("");
        require(success, "Transfer failed");

        vm.stopBroadcast();

        uint256 balanceAfter = address(fbs).balance;
        console.log("Contract balance after:", balanceAfter);
        console.log("Amount sent:", sendAmount);
        console.log("Total funds received:", fbs.totalFundsReceived());
        console.log("\nNote: This triggered the receive() function");
    }
}
