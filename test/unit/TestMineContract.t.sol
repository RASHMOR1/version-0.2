// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {MineContract} from "../../src/MineContract.sol";
import {EmployeesContract} from "../../src/DynamicNFTs/EmployeesContract.sol";
import {MachineryAndEquipmentContract} from "../../src/DynamicNFTs/MachineryAndEquipmentContract.sol";

contract TestMineContract is Test {
    MineContract mineContract;
    EmployeesContract employeesContract;
    MachineryAndEquipmentContract machineryAndEquipmentContract;
    address mechanic1;
    address mechanic2;
    address[] mineAddresses;

    address admin;

    function setUp() public {
        admin = payable(makeAddr("admin"));
        mechanic1 = payable(makeAddr("mechanic1"));
        mechanic2 = payable(makeAddr("mechanic2"));
        vm.deal(admin, 10 ether);
        vm.deal(mechanic1, 10 ether);
        vm.deal(mechanic2, 10 ether);
        vm.startPrank(admin);
        mineContract = new MineContract();
        mineAddresses.push(address(mineContract));
        employeesContract = new EmployeesContract();
        machineryAndEquipmentContract = new MachineryAndEquipmentContract();
        mineContract.setEmployeesContractAddress(address(employeesContract));
        mineContract.setMachineryAndEquipmentContractAddress(address(machineryAndEquipmentContract));
        employeesContract.mint(address(mineContract), "miner", "mine", 34, 34, 34, "skdjc");
        employeesContract.mint(address(mineContract), "driver", "mine", 34, 34, 34, "skdjc");
        employeesContract.mint(address(mineContract), "ceo", "mine", 34, 34, 34, "skdjc");
        machineryAndEquipmentContract.mint(address(mineContract), 1, 1, 1, 1);
        machineryAndEquipmentContract.mint(address(mineContract), 2, 2, 2, 2);
        machineryAndEquipmentContract.mint(address(mineContract), 3, 3, 3, 3);
        machineryAndEquipmentContract.fillMineAddresses(mineAddresses);
        mineContract.setAllowedToRepair(mechanic1, true);
        vm.stopPrank();
        vm.startPrank(address(mineContract));

        employeesContract.setApprovalForAll(admin, true);
        machineryAndEquipmentContract.setApprovalForAll(admin, true);

        vm.stopPrank();
    }

    function test__CanFireEmployees() public {
        vm.startPrank(admin);
        mineContract.fireEmployee(1);
        vm.expectRevert();
        employeesContract.ownerOf(1) == address(0);
        vm.stopPrank();
    }

    function test__DecomissionMachineryWorksCorrectly() public {
        vm.startPrank(admin);
        mineContract.decomissionMachinery(0);
        vm.stopPrank();
        vm.expectRevert();
        machineryAndEquipmentContract.ownerOf(0);
        assert(machineryAndEquipmentContract.tokenIdToVehicleModel(0) == 0);
        MachineryAndEquipmentContract.ChangeableMetadata memory newMetadata =
            machineryAndEquipmentContract.getTokenMetadata(0);
        assertEq(newMetadata.machineryCondition, 0);
        assertEq(newMetadata.yearOfManufacture, 0);
        assertEq(newMetadata.serialNumber, 0);
    }

    function test__TransferMachineryAndEmployees() public {
        address someAddress = makeAddr("someAddress");
        vm.startPrank(admin);
        mineContract.transferMachinery(0, someAddress);
        mineContract.transferEmployee(0, someAddress);
        vm.stopPrank();
        assert(machineryAndEquipmentContract.ownerOf(0) == someAddress);
        assert(employeesContract.ownerOf(0) == someAddress);
    }

    function test__SetApprovalForAllMachineryAndEmployees() public {
        address someAddress = makeAddr("someAddress");
        vm.startPrank(admin);
        mineContract.setApprovalForAllEmployees(someAddress, true);
        mineContract.setApprovalForAllMachinery(someAddress, true);
        vm.stopPrank();
        vm.startPrank(someAddress);
        employeesContract.fireEmployee(0);
        machineryAndEquipmentContract.decommissionMachinery(0);
        vm.stopPrank();
        vm.expectRevert();
        employeesContract.ownerOf(0);
        MachineryAndEquipmentContract.ChangeableMetadata memory newMetadata =
            machineryAndEquipmentContract.getTokenMetadata(0);
        assertEq(newMetadata.machineryCondition, 0);
    }

    function test__ChangeEmployeeMetadata() public {
        vm.startPrank(admin);
        mineContract.changeEmployeeMetadata(0, "a", "a", 99, 99, 99);
        vm.stopPrank();
        EmployeesContract.ChangeableMetadata memory newMetadata = employeesContract.getTokenMetadata(0);
        assertEq(newMetadata.currentPosition, "a");
        assertEq(newMetadata.placeOfWork, "a");
        assertEq(newMetadata.contactInformation, 99);
        assertEq(newMetadata.salary, 99);
        assertEq(newMetadata.rating, 99);
    }

    function test__AssignEmployeeToMachinery() public {
        vm.startPrank(admin);
        vm.expectRevert();
        mineContract.assignEmployeeToMachinery(99, 99);
        vm.expectRevert();
        mineContract.assignEmployeeToMachinery(1, 99);
        vm.expectRevert();
        mineContract.assignEmployeeToMachinery(99, 1);
        mineContract.assignEmployeeToMachinery(1, 1);
        vm.stopPrank();
        assert(mineContract.employeeTokenIdToMachineryTokenId(1) == 1);
    }

    function test__AssignEmployeeHisPersonalAddress() public {
        address someAddress = makeAddr("someAddress");
        vm.startPrank(admin);
        vm.expectRevert();
        mineContract.assignEmployeeHisPersonalAddress(99, someAddress);
        mineContract.assignEmployeeHisPersonalAddress(0, someAddress);
        vm.stopPrank();
        assert(mineContract.employeeTokenIdToTheirPersonalAddress(0) == someAddress);
    }
}
