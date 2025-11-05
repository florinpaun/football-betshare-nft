// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {FootballBetShare} from "../src/FootballBetShare.sol";

// Usage: forge script script/08_RevealTicket.s.sol:RevealTicket --rpc-url $RPC_URL --broadcast
contract RevealTicket is Script {
    function run() external {
        require(vm.envExists("CONTRACT_ADDRESS"), "CONTRACT_ADDRESS not set");
        require(vm.envExists("USER_PRIVATE_KEY"), "USER_PRIVATE_KEY not set");
        require(vm.envExists("TICKET_ID"), "TICKET_ID not set");

        address payable contractAddress = payable(
            vm.envAddress("CONTRACT_ADDRESS")
        );
        uint256 userPrivateKey = vm.envUint("USER_PRIVATE_KEY");
        uint256 ticketId = vm.envUint("TICKET_ID");

        vm.startBroadcast(userPrivateKey);

        FootballBetShare fbs = FootballBetShare(contractAddress);

        // Reveal with the same outcomes and salt used during creation
        uint256[] memory outcomes = new uint256[](3);
        outcomes[0] = 1; // Home
        outcomes[1] = 0; // Draw
        outcomes[2] = 2; // Away

        string memory salt = "my_secret_salt_123";

        fbs.revealTicket(ticketId, outcomes, salt);

        console.log("Ticket", ticketId, "revealed successfully");
        console.log("Outcomes: [1, 0, 2]");

        // Check if winning
        bool isWinning = fbs.checkTicketWin(ticketId);
        console.log("Is Winning:", isWinning);

        vm.stopBroadcast();
    }
}
