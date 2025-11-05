// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {FootballBetShare} from "../src/FootballBetShare.sol";

// Usage: forge script script/Deploy.s.sol:DeployFootballBetShare --rpc-url http://127.0.0.1:8545 --broadcast

contract DeployFootballBetShare is Script {
    function run() external returns (FootballBetShare) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        FootballBetShare fbs = new FootballBetShare();

        console.log("FootballBetShare deployed at:", address(fbs));
        console.log("Owner:", fbs.owner());

        vm.stopBroadcast();

        return fbs;
    }
}
