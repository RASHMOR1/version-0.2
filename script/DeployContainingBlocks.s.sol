// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ContainingBlock} from "../src/ContainingBlock.sol";
import {BlockAbstract} from "../src/Abstract/BlockAbstract.sol";

contract DeployScript is Script {
    BlockAbstract.ReadinessForMining readinessStatus = BlockAbstract.ReadinessForMining.NotDone;

    event Done(ContractAddresses indexed contractAddresses);

    struct ContractAddresses {
        address[] motherContracts;
        address[][] daughterContracts;
    }

    ContractAddresses contractAddresses;

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY_ANVIL"));
        // Containing Blocks deployment
        for (uint256 i = 0; i < 5; i++) {
            ContainingBlock containingBlock =
                new ContainingBlock(345, readinessStatus, int256(i), 3456, -3453, address(0));
            contractAddresses.motherContracts.push(address(containingBlock));
            address[] memory daughterContractsForCurrentMother;
            // for each containing block its daughter contract is deployed
            for (uint256 j = 0; j < 10; j++) {
                ContainingBlock daughterContainingBlock = new ContainingBlock(
                    345, readinessStatus, int256(j), 3456, -3453, contractAddresses.motherContracts[i]
                );
                daughterContractsForCurrentMother[j] = address(daughterContainingBlock);
            }

            contractAddresses.daughterContracts.push(daughterContractsForCurrentMother);
            //populating daughter blocks
            containingBlock.populateDaughterBlocks(daughterContractsForCurrentMother);
        }
        emit Done(contractAddresses);

        vm.stopBroadcast();
    }
}
