// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {FootballBetShare} from "../src/FootballBetShare.sol";

// Usage: forge script script/06_CloseGames.s.sol:CloseGames --rpc-url $RPC_URL --broadcast

contract CloseGames is Script {
    function run() external {
        require(vm.envExists("CONTRACT_ADDRESS"), "CONTRACT_ADDRESS not set");
        require(vm.envExists("PRIVATE_KEY"), "PRIVATE_KEY not set");

        address payable contractAddress = payable(
            vm.envAddress("CONTRACT_ADDRESS")
        );
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        FootballBetShare fbs = FootballBetShare(contractAddress);

        // Close games 0, 1, 2
        fbs.closeGame(0);
        console.log("Game 0 closed");

        fbs.closeGame(1);
        console.log("Game 1 closed");

        fbs.closeGame(2);
        console.log("Game 2 closed");

        vm.stopBroadcast();

        console.log("\n=== Games Closed Successfully ===");
    }
}
