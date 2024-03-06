// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {MineContract} from "../src/MineContract.sol";

contract DeployMineContract is Script {
    MineContract mineContract;

    function run() public {
        vm.startBroadcast();

        mineContract = new MineContract();

        vm.stopBroadcast();
    }
}
//  forge script script/DeployMineContract.s.sol:DeployMineContract --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv
