// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {FootballBetShare} from "../src/FootballBetShare.sol";

// Usage: forge script script/01_CreateGames.s.sol:CreateGames --rpc-url $RPC_URL --broadcast

contract CreateGames is Script {
    function run() external {
        require(vm.envExists("CONTRACT_ADDRESS"), "CONTRACT_ADDRESS not set");
        require(vm.envExists("PRIVATE_KEY"), "DEPLOYER_PRIVATE_KEY not set");
        address payable contractAddress = payable(
            vm.envAddress("CONTRACT_ADDRESS")
        );
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        FootballBetShare fbs = FootballBetShare(contractAddress);

        // Create multiple games
        fbs.createGame("Manchester United", "Liverpool", 250, 320, 280);
        console.log("Game 0 created: Manchester United vs Liverpool");

        fbs.createGame("Barcelona", "Real Madrid", 220, 310, 320);
        console.log("Game 1 created: Barcelona vs Real Madrid");

        fbs.createGame("Bayern Munich", "Dortmund", 180, 350, 450);
        console.log("Game 2 created: Bayern Munich vs Dortmund");

        vm.stopBroadcast();

        console.log("\n=== Games Created Successfully ===");
    }
}
