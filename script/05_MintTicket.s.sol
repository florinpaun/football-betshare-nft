// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {FootballBetShare} from "../src/FootballBetShare.sol";

// Usage: forge script script/05_MintTicket.s.sol:MintTicket --rpc-url $RPC_URL --broadcast

contract MintTicket is Script {
    function run() external {
        require(vm.envExists("CONTRACT_ADDRESS"), "CONTRACT_ADDRESS not set");
        require(vm.envExists("TICKET_ID"), "TICKET_ID not set");
        require(
            vm.envExists("USER_PRIVATE_KEY_MINTER"),
            "USER_PRIVATE_KEY_MINTER not set"
        );
        require(vm.envExists("AMOUNT_TO_MINT"), "AMOUNT_TO_MINT not set");

        address payable contractAddress = payable(
            vm.envAddress("CONTRACT_ADDRESS")
        );
        uint256 userPrivateKey = vm.envUint("USER_PRIVATE_KEY_MINTER");
        uint256 ticketId = vm.envUint("TICKET_ID");
        uint256 amount = vm.envUint("AMOUNT_TO_MINT");

        vm.startBroadcast(userPrivateKey);

        FootballBetShare fbs = FootballBetShare(contractAddress);

        // Get ticket info to know bet amount
        (, , , , uint256 betAmount, , , ) = fbs.getTicket(ticketId);

        uint256 totalValue = betAmount * amount;

        fbs.mintTicket{value: totalValue}(ticketId, amount);

        console.log("Minted", amount, "tickets for ticket ID:", ticketId);
        console.log("Total paid:", totalValue);

        vm.stopBroadcast();
    }
}
