// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {FootballBetShare} from "../src/FootballBetShare.sol";

// Usage: forge script script/04_ReadTicket.s.sol:ReadTicket --rpc-url $RPC_URL

contract ReadTicket is Script {
    function run() external view {
        require(vm.envExists("CONTRACT_ADDRESS"), "CONTRACT_ADDRESS not set");
        require(vm.envExists("TICKET_ID"), "TICKET_ID not set");

        address payable contractAddress = payable(
            vm.envAddress("CONTRACT_ADDRESS")
        );
        uint256 ticketId = vm.envUint("TICKET_ID");

        FootballBetShare fbs = FootballBetShare(contractAddress);

        (
            uint256 id,
            address creator,
            uint256 finalOdds,
            bool revealed,
            uint256 betAmount,
            uint256 totalMinted,
            uint256 totalStaked,
            bool settled
        ) = fbs.getTicket(ticketId);

        console.log("==========================================");
        console.log("Ticket ID:", id);
        console.log("Creator:", creator);
        console.log("Final Odds:", finalOdds);
        console.log("Revealed:", revealed);
        console.log("Bet Amount:", betAmount);
        console.log("Total Minted:", totalMinted);
        console.log("Total Staked:", totalStaked);
        console.log("Settled:", settled);
        console.log("==========================================");

        // Get ticket games
        FootballBetShare.TicketGame[] memory games = fbs.getTicketGames(
            ticketId
        );
        console.log("\nGames in ticket:", games.length);
        console.log(games[3].selectedOdds);
        /*
        for (uint256 i = 0; i < games.length; i++) {
            console.log(
                "Game",
                i,
                "- ID:",
                games[i].gameId,
                "Selected Odds:",
                games[i].selectedOdds
            );
        }

        // If revealed, show outcomes
        if (revealed) {
            uint256[] memory outcomes = fbs.getRevealedOutcomes(ticketId);
            console.log("\nRevealed Outcomes:");
            for (uint256 i = 0; i < outcomes.length; i++) {
                console.log(
                    "Game",
                    i,
                    "- Outcome:",
                    outcomes[i],
                    "(0=Draw, 1=Home, 2=Away)"
                );
            }
        }
        */
    }
}
