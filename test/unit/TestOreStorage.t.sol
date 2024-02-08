// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {LeafBlock} from "../../src/LeafBlock.sol";
import {BlockAbstract} from "../../src/Abstract/BlockAbstract.sol";
import {OreStorage} from "../../src/OreStorage.sol";
import {OreSlot} from "../../src/OreSlot.sol";
import {IOreStorage} from "../../src/Interfaces/IOreStorage.sol";

contract TestContainingBlock is Test {
    event OreStorage__OreSlotsPopulated();

    OreStorage oreStorage;
    OreSlot oreSlot0;
    OreSlot oreSlot1;
    OreSlot oreSlot2;
    OreSlot oreSlot3;
    OreSlot oreSlot4;
    address[] oreSlots;

    function setUp() public {
        oreSlot0 = new OreSlot();
        oreSlot1 = new OreSlot();
        oreSlot2 = new OreSlot();
        oreSlot3 = new OreSlot();
        oreSlot4 = new OreSlot();
        oreSlots.push(address(oreSlot0));
        oreSlots.push(address(oreSlot1));
        oreSlots.push(address(oreSlot2));
        oreSlots.push(address(oreSlot3));
        oreSlots.push(address(oreSlot4));
        oreStorage = new OreStorage();
    }
    // addToStorage tested in TestLeafBlock

    function test__populateOreStorage() public {
        vm.expectEmit(false, false, false, false);
        emit OreStorage__OreSlotsPopulated();
        oreStorage.populateOreStorage(oreSlots);
        assert(oreStorage.storageSlotsAddresses(0) == oreSlots[0]);
        assert(oreStorage.storageSlotsAddresses(2) == oreSlots[2]);
        assert(oreStorage.storageSlotsAddresses(3) == oreSlots[3]);
        assert(oreStorage.storageSlotsToAddress(1) == oreSlots[1]);
        assert(oreStorage.storageSlotsToAddress(4) == oreSlots[4]);
    }
}
