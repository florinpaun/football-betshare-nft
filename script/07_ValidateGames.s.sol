// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {FootballBetShare} from "../src/FootballBetShare.sol";

// Usage: forge script script/07_ValidateGames.s.sol:ValidateGames --rpc-url $RPC_URL --broadcast

contract ValidateGames is Script {
    function run() external {
        require(vm.envExists("CONTRACT_ADDRESS"), "CONTRACT_ADDRESS not set");
        require(vm.envExists("PRIVATE_KEY"), "PRIVATE_KEY not set");

        address payable contractAddress = payable(
            vm.envAddress("CONTRACT_ADDRESS")
        );
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        FootballBetShare fbs = FootballBetShare(contractAddress);

        // Validate games with results
        // Game 0: Home wins (1)
        fbs.validateGameResult(0, FootballBetShare.Outcome.Home);
        console.log("Game 0 validated: Home wins");

        // Game 1: Draw (0)
        fbs.validateGameResult(1, FootballBetShare.Outcome.Draw);
        console.log("Game 1 validated: Draw");

        // Game 2: Away wins (2)
        fbs.validateGameResult(2, FootballBetShare.Outcome.Away);
        console.log("Game 2 validated: Away wins");

        vm.stopBroadcast();

        console.log("\n=== Games Validated Successfully ===");
    }
}
