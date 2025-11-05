// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {FootballBetShare} from "../src/FootballBetShare.sol";

// Usage: forge script script/16_EmergencyWithdraw.s.sol:EmergencyWithdraw --rpc-url $RPC_URL --broadcast

contract EmergencyWithdraw is Script {
    function run() external {
        require(vm.envExists("CONTRACT_ADDRESS"), "CONTRACT_ADDRESS not set");
        require(vm.envExists("PRIVATE_KEY"), "PRIVATE_KEY not set");

        address payable contractAddress = payable(
            vm.envAddress("CONTRACT_ADDRESS")
        );
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        FootballBetShare fbs = FootballBetShare(contractAddress);
        address owner = fbs.owner();

        uint256 contractBalanceBefore = address(fbs).balance;
        uint256 ownerBalanceBefore = owner.balance;

        console.log("==========================================");
        console.log("EMERGENCY WITHDRAWAL");
        console.log("==========================================");
        console.log("WARNING: This will withdraw ALL funds from the contract!");
        console.log("Contract balance:", contractBalanceBefore);
        console.log("Owner balance:", ownerBalanceBefore);
        console.log("==========================================");

        vm.startBroadcast(deployerPrivateKey);

        // Emergency withdraw all funds
        fbs.emergencyWithdraw();

        vm.stopBroadcast();

        uint256 contractBalanceAfter = address(fbs).balance;
        uint256 ownerBalanceAfter = owner.balance;

        console.log("\nContract balance after:", contractBalanceAfter);
        console.log("Owner balance after:", ownerBalanceAfter);
        console.log("Total withdrawn:", contractBalanceBefore);
        console.log("==========================================");
    }
}
