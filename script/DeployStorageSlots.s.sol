// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {OreStorage} from "../src/OreStorage.sol";
import {OreSlot} from "../src/OreSlot.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract DeployLeafBlocks is Script {
    OreStorage oreStorage;

    address[] oreSlots;

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY_ANVIL"));
        // lets say storage has 10 slots
        for (uint256 i = 0; i < 10; i++) {
            OreSlot oreSlot = new OreSlot();
            oreSlot.setPriceFeed(AggregatorV3Interface(address(0))); // input address of the price feed
            oreSlots.push(address(oreSlot));
        }
        oreStorage = new OreStorage();
        oreStorage.populateOreStorage(oreSlots);
        vm.stopBroadcast();
    }
}
