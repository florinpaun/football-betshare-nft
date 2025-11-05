// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {FootballBetShare} from "../src/FootballBetShare.sol";

// Usage: forge script script/02_ReadGames.s.sol:ReadGames --rpc-url $RPC_URL

contract ReadGames is Script {
    function run() external view {
        require(vm.envExists("CONTRACT_ADDRESS"), "CONTRACT_ADDRESS not set");

        address payable contractAddress = payable(
            vm.envAddress("CONTRACT_ADDRESS")
        );
        FootballBetShare fbs = FootballBetShare(contractAddress);

        uint256 gameCounter = fbs.gameCounter();
        console.log("Total games:", gameCounter);
        console.log("");

        for (uint256 i = 0; i < gameCounter; i++) {
            FootballBetShare.Game memory game = fbs.getGame(i);

            console.log("==========================================");
            console.log("Game ID:", game.id);
            console.log("Home Team:", game.homeTeam);
            console.log("Away Team:", game.awayTeam);
            console.log("Odds Home:", game.oddsHome);
            console.log("Odds Draw:", game.oddsDraw);
            console.log("Odds Away:", game.oddsAway);
            console.log(
                "Status:",
                uint8(game.status),
                "(0=Created, 1=Closed, 2=Validated)"
            );
            console.log("Result Set:", game.resultSet);
            if (game.resultSet) {
                console.log(
                    "Result:",
                    uint8(game.result),
                    "(0=Draw, 1=Home, 2=Away)"
                );
            }
            console.log("==========================================");
            console.log("");
        }
    }
}
