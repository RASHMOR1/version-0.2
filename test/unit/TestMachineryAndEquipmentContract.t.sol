// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

import {MachineryAndEquipmentContract} from "../../src/DynamicNFTs/MachineryAndEquipmentContract.sol";

contract TestEmployeesContract is Test {
    address mineContract;
    MachineryAndEquipmentContract machineryAndEquipmentContract;

    address admin;
    address mechanic1;
    address mechanic2;
    address[] minesAddresses;

    function setUp() public {
        admin = payable(makeAddr("admin"));
        mineContract = payable(makeAddr("contract"));
        mechanic1 = payable(makeAddr("mechanic1"));
        mechanic2 = payable(makeAddr("mechanic2"));
        vm.deal(admin, 10 ether);
        vm.deal(mechanic1, 10 ether);
        vm.deal(mechanic2, 10 ether);
        vm.startPrank(admin);

        machineryAndEquipmentContract = new MachineryAndEquipmentContract();

        machineryAndEquipmentContract.mint(mineContract, 34, 34, 34, 34);
        machineryAndEquipmentContract.mint(mineContract, 3, 34, 34, 34);
        machineryAndEquipmentContract.mint(mineContract, 4, 34, 34, 34);
        minesAddresses.push(mineContract);
        machineryAndEquipmentContract.fillMineAddresses(minesAddresses);

        vm.stopPrank();

        vm.startPrank(mineContract);
        machineryAndEquipmentContract.setApprovalForAll(admin, true);
        machineryAndEquipmentContract.setAllowedToRepair(mechanic1, true);
        vm.stopPrank();
    }

    function test__MintFunctionWorks() public view {
        assert(machineryAndEquipmentContract.ownerOf(0) == mineContract);
        assert(machineryAndEquipmentContract.ownerOf(1) == mineContract);
        assert(machineryAndEquipmentContract.ownerOf(2) == mineContract);
        assert(machineryAndEquipmentContract.tokenOfOwnerByIndex(mineContract, 0) == 0);
        assert(machineryAndEquipmentContract.tokenOfOwnerByIndex(mineContract, 1) == 1);
        assert(machineryAndEquipmentContract.tokenOfOwnerByIndex(mineContract, 2) == 2);
    }

    function test__AuthoriseMechanicsCanRepairTheMachinery() public {
        vm.startPrank(mechanic1);
        machineryAndEquipmentContract.makeRepairsToMachinery(0, "repairs", 88);
        vm.stopPrank();

        MachineryAndEquipmentContract.ChangeableMetadata memory newMetadata =
            machineryAndEquipmentContract.getTokenMetadata(0);
        assertEq(newMetadata.machineryCondition, 88);
        assertEq(newMetadata.yearOfManufacture, 34);
        assertEq(newMetadata.serialNumber, 34);
    }

    function test__UnauthorizedMechanicsCantRepairTheMachinery() public {
        vm.startPrank(mechanic2);
        vm.expectRevert();
        machineryAndEquipmentContract.makeRepairsToMachinery(0, "repairs", 88);
        vm.stopPrank();
    }

    function test__modifierTokenIdExistsWorksCorrectly() public {
        vm.startPrank(admin);
        vm.expectRevert();
        machineryAndEquipmentContract.decommissionMachinery(9);
        vm.stopPrank();
        vm.startPrank(mechanic1);
        vm.expectRevert();
        machineryAndEquipmentContract.makeRepairsToMachinery(99, "repairs", 99);
        vm.stopPrank();
    }

    function test_baseURI() public {
        vm.startPrank(makeAddr("someAddress"));
        vm.expectRevert();
        machineryAndEquipmentContract.setBaseURI("https://abc/");
        vm.stopPrank();
        vm.startPrank(admin);
        machineryAndEquipmentContract.setBaseURI("https://abc/");
        vm.stopPrank();
        assertEq(machineryAndEquipmentContract.tokenURI(0), "https://abc/34");
    }
}
