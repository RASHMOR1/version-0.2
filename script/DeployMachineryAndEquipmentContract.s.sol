// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {MachineryAndEquipmentContract} from "../src/DynamicNFTs/MachineryAndEquipmentContract.sol";

contract DeployMachineryAndEquipmentContract is Script {
    MachineryAndEquipmentContract machineryAndEquipmentContract;

    function run() public {
        vm.startBroadcast();

        machineryAndEquipmentContract = new MachineryAndEquipmentContract();

        vm.stopBroadcast();
    }
}
// forge script script/DeployMachineryAndEquipmentContract.s.sol:DeployMachineryAndEquipmentContract --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv
