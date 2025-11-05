// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {FootballBetShare} from "../src/FootballBetShare.sol";

// Usage: forge script script/15_CheckContractBalance.s.sol:CheckContractBalance --rpc-url $RPC_URL --broadcast

contract CheckContractBalance is Script {
    function run() external view {
        address payable contractAddress = payable(
            vm.envAddress("CONTRACT_ADDRESS")
        );

        FootballBetShare fbs = FootballBetShare(contractAddress);

        uint256 actualBalance = address(fbs).balance;
        uint256 trackedBalance = fbs.contractBalance();
        uint256 totalFundsReceived = fbs.totalFundsReceived();

        console.log("==========================================");
        console.log("CONTRACT BALANCE INFORMATION");
        console.log("==========================================");
        console.log("Actual contract balance:", actualBalance);
        console.log("Tracked contract balance:", trackedBalance);
        console.log("Total funds received:", totalFundsReceived);
        console.log("==========================================");
    }
}
