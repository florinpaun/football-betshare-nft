// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {FootballBetShare} from "../src/FootballBetShare.sol";

// Usage: forge script script/03_CreateTicket.s.sol:CreateTicket --rpc-url $RPC_URL --broadcast

contract CreateTicket is Script {
    function run() external {
        require(vm.envExists("CONTRACT_ADDRESS"), "CONTRACT_ADDRESS not set");
        require(vm.envExists("USER_PRIVATE_KEY"), "USER_PRIVATE_KEY not set");
        require(vm.envExists("SALT"), "SALT not set");

        address payable contractAddress = payable(
            vm.envAddress("CONTRACT_ADDRESS")
        );
        uint256 userPrivateKey = vm.envUint("USER_PRIVATE_KEY");
        string memory salt = vm.envString("SALT");

        vm.startBroadcast(userPrivateKey);

        FootballBetShare fbs = FootballBetShare(contractAddress);

        // Create a ticket with games 0, 1, 2
        uint256[] memory gameIds = new uint256[](3);
        gameIds[0] = 0;
        gameIds[1] = 1;
        gameIds[2] = 2;

        // Outcomes: 1=Home, 0=Draw, 2=Away
        uint256[] memory outcomes = new uint256[](3);
        outcomes[0] = 1; // Manchester United wins
        outcomes[1] = 0; // Barcelona vs Real Madrid draw
        outcomes[2] = 2; // Dortmund wins

        address creator = vm.addr(userPrivateKey);

        // Create hash
        bytes32 hiddenDataHash = keccak256(
            abi.encodePacked(outcomes, salt, creator)
        );

        uint256 betAmount = 0.01 ether;

        uint256 ticketId = fbs.createTicket(gameIds, hiddenDataHash, betAmount);

        console.log("Ticket created with ID:", ticketId);
        console.log("Hidden data hash:", vm.toString(hiddenDataHash));
        console.log("Bet amount:", betAmount);
        console.log("\nRemember to save your salt:", salt);
        console.log("Outcomes selected: [1, 0, 2] (Home, Draw, Away)");

        vm.stopBroadcast();
    }
}
