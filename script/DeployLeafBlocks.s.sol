// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {LeafBlock} from "../src/LeafBlock.sol";
import {BlockAbstract} from "../src/Abstract/BlockAbstract.sol";
import {IOreStorage} from "../src/Interfaces/IOreStorage.sol";

contract DeployLeafBlocks is Script {
    address[] preLeafBlockAddreses; // this addresses will be retrived during DeployContainingblocks
    address storageContract; // this addresse will be retrived during DeployContainingblocks
    BlockAbstract.ReadinessForMining readinessStatus = BlockAbstract.ReadinessForMining.NotDone;

    address[][] allLeafBlocksArray;

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY_ANVIL"));
        for (uint256 i = 0; i < preLeafBlockAddreses.length; i++) {
            // for each containingBlock 10 blocks will be created. the number of LeafBlocks can differ depending on block parameters
            address[] memory leafBlocks;
            for (uint256 j = 0; i < preLeafBlockAddreses.length; j++) {
                LeafBlock leafBlock = new LeafBlock(
                    0, readinessStatus, 0, 0, 0, address(preLeafBlockAddreses[i]), IOreStorage(storageContract)
                );
                leafBlocks[j] = address(leafBlock);
            }
            allLeafBlocksArray.push(leafBlocks);
        }
        vm.stopBroadcast();
    }
}
