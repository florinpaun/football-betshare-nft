// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {FootballBetShare} from "../src/FootballBetShare.sol";

// Usage: forge script script/11_FundContract.s.sol:FundContract --rpc-url $RPC_URL --broadcast

contract FundContract is Script {
    function run() external {
        require(vm.envExists("CONTRACT_ADDRESS"), "CONTRACT_ADDRESS not set");
        require(vm.envExists("PRIVATE_KEY"), "DEPLOYER_PRIVATE_KEY not set");

        address payable contractAddress = payable(
            vm.envAddress("CONTRACT_ADDRESS")
        );
        uint256 userPrivateKey = vm.envUint("USER_PRIVATE_KEY");

        FootballBetShare fbs = FootballBetShare(contractAddress);

        uint256 balanceBefore = address(fbs).balance;
        console.log("Contract balance before:", balanceBefore);

        vm.startBroadcast(userPrivateKey);

        // Fund the contract with 10 ETH
        uint256 fundAmount = 10 ether;
        fbs.fundContract{value: fundAmount}();

        vm.stopBroadcast();

        uint256 balanceAfter = address(fbs).balance;
        console.log("Contract balance after:", balanceAfter);
        console.log("Amount funded:", fundAmount);
        console.log("Total funds received:", fbs.totalFundsReceived());
    }
}
