// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {FootballBetShare} from "../src/FootballBetShare.sol";

// Usage: forge script script/14_WithdrawFunds.s.sol:WithdrawFunds --rpc-url $RPC_URL --broadcast

contract WithdrawFunds is Script {
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

        console.log("Contract balance before:", contractBalanceBefore);
        console.log("Owner balance before:", ownerBalanceBefore);

        vm.startBroadcast(deployerPrivateKey);

        uint256 withdrawAmount = 2 ether;
        fbs.withdrawFunds(withdrawAmount);

        vm.stopBroadcast();

        uint256 contractBalanceAfter = address(fbs).balance;
        uint256 ownerBalanceAfter = owner.balance;

        console.log("\nContract balance after:", contractBalanceAfter);
        console.log("Owner balance after:", ownerBalanceAfter);
        console.log("Amount withdrawn:", withdrawAmount);
        console.log("Owner received:", ownerBalanceAfter - ownerBalanceBefore);
    }
}
