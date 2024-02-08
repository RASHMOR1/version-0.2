// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {LeafBlock} from "../../src/LeafBlock.sol";
import {BlockAbstract} from "../../src/Abstract/BlockAbstract.sol";
import {OreStorage} from "../../src/OreStorage.sol";
import {OreSlot} from "../../src/OreSlot.sol";
import {IOreStorage} from "../../src/Interfaces/IOreStorage.sol";

contract TestContainingBlock is Test {
    event LeafBlock__TransferToStorageSlot(uint256 indexed slotNumber, uint256 indexed volume, uint256 indexed quality);

    LeafBlock leafBlock;
    OreStorage oreStorage;
    OreSlot oreSlot;

    address[] oreSlots;

    function setUp() public {
        oreSlot = new OreSlot();
        oreSlots.push(address(oreSlot));
        oreStorage = new OreStorage();
        leafBlock = new LeafBlock(
            32,
            BlockAbstract.ReadinessForMining.ReadyToBeDone,
            566,
            -2342,
            3,
            address(0),
            IOreStorage(address(oreStorage))
        );

        oreStorage.populateOreStorage(oreSlots);
    }

    function test__StoraContractIsCorrect() public view {
        assert(leafBlock.storageContract() == IOreStorage(address(oreStorage)));
    }

    function test__TransferToStorageSlot() public {
        uint256 slotNumber = 0;
        uint256 volume = 3453;
        uint256 quality = 43;
        vm.expectEmit(true, true, true, true);
        emit LeafBlock__TransferToStorageSlot(slotNumber, volume, quality);
        leafBlock.transferToStorageSlot(slotNumber, volume, quality);
        assert(oreSlot.isInQuality(quality) == true);
        assert(oreSlot.qualityToVolume(quality) == volume);
        assert(oreSlot.totalVolume() == volume);
        assert(oreSlot.qualities(0) == quality);
    }
}
