// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {FootballBetShare} from "../src/FootballBetShare.sol";

// Usage: forge script script/10_ClaimWinnings.s.sol:ClaimWinnings --rpc-url $RPC_URL --broadcast
contract ClaimWinnings is Script {
    function run() external {
        require(vm.envExists("CONTRACT_ADDRESS"), "CONTRACT_ADDRESS not set");
        require(vm.envExists("USER_PRIVATE_KEY"), "USER_PRIVATE_KEY not set");
        require(vm.envExists("TICKET_ID"), "TICKET_ID not set");

        address payable contractAddress = payable(
            vm.envAddress("CONTRACT_ADDRESS")
        );
        uint256 userPrivateKey = vm.envUint("USER_PRIVATE_KEY");
        uint256 ticketId = vm.envUint("TICKET_ID");

        address userAddress = vm.addr(userPrivateKey);
        uint256 balanceBefore = userAddress.balance;

        vm.startBroadcast(userPrivateKey);

        FootballBetShare fbs = FootballBetShare(contractAddress);

        fbs.claimWinnings(ticketId);

        vm.stopBroadcast();

        uint256 balanceAfter = userAddress.balance;
        uint256 claimed = balanceAfter - balanceBefore;

        console.log("Winnings claimed for ticket", ticketId);
        console.log("Amount claimed:", claimed);
    }
}
