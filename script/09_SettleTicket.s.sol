// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {FootballBetShare} from "../src/FootballBetShare.sol";

// Usage: forge script script/09_SettleTicket.s.sol:SettleTicket --rpc-url $RPC_URL --broadcast
contract SettleTicket is Script {
    function run() external {
        require(vm.envExists("CONTRACT_ADDRESS"), "CONTRACT_ADDRESS not set");
        require(vm.envExists("PRIVATE_KEY"), "PRIVATE_KEY not set");
        require(vm.envExists("TICKET_ID"), "TICKET_ID not set");

        address payable contractAddress = payable(
            vm.envAddress("CONTRACT_ADDRESS")
        );
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        uint256 ticketId = vm.envUint("TICKET_ID");

        vm.startBroadcast(deployerPrivateKey);

        FootballBetShare fbs = FootballBetShare(contractAddress);

        fbs.settleTicket(ticketId);

        console.log("Ticket", ticketId, "settled successfully");

        vm.stopBroadcast();
    }
}
