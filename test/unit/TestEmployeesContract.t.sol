// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

import {EmployeesContract} from "../../src/DynamicNFTs/EmployeesContract.sol";

contract TestEmployeesContract is Test {
    address mineContract;
    EmployeesContract employeesContract;

    address admin;

    function setUp() public {
        admin = payable(makeAddr("admin"));
        mineContract = payable(makeAddr("contract"));
        vm.deal(admin, 10 ether);
        vm.startPrank(admin);

        employeesContract = new EmployeesContract();

        employeesContract.mint(mineContract, "miner", "mine", 34, 34, 34, "skdjc");
        employeesContract.mint(mineContract, "driver", "mine", 34, 34, 34, "skdjc");
        employeesContract.mint(mineContract, "ceo", "mine", 34, 34, 34, "skdjc");
        vm.stopPrank();

        vm.startPrank(mineContract);
        employeesContract.setApprovalForAll(admin, true);
        vm.stopPrank();
    }

    function test__MintFunctionWorks() public view {
        assert(employeesContract.ownerOf(0) == mineContract);
        assert(employeesContract.ownerOf(1) == mineContract);
        assert(employeesContract.ownerOf(2) == mineContract);
        assert(employeesContract.tokenOfOwnerByIndex(mineContract, 0) == 0);
        assert(employeesContract.tokenOfOwnerByIndex(mineContract, 1) == 1);
        assert(employeesContract.tokenOfOwnerByIndex(mineContract, 2) == 2);
        assert(employeesContract.isApprovedForAll(mineContract, admin) == true);
    }

    function test__onlyCurrentOwnerCanUpdateTokenMetadata() public {
        vm.startPrank(makeAddr("someAddress"));
        vm.expectRevert();
        employeesContract.updateTokenMetadata(0, "miner2", "mine", 34, 34, 34);
        vm.stopPrank();
    }

    function test__updateTokenMetadataWorksCorrectly() public {
        vm.startPrank(mineContract);
        employeesContract.updateTokenMetadata(0, "miner2", "mine", 34, 34, 34);
        EmployeesContract.ChangeableMetadata memory newMetadata = employeesContract.getTokenMetadata(0);
        vm.stopPrank();
        assertEq(newMetadata.currentPosition, "miner2");
    }

    function test__fireEmployeeWorksCorrectly() public {
        vm.startPrank(mineContract);
        employeesContract.fireEmployee(0);
        vm.expectRevert();
        employeesContract.ownerOf(0) == address(0);
        EmployeesContract.ChangeableMetadata memory newMetadata = employeesContract.getTokenMetadata(0);
        assertEq(newMetadata.currentPosition, "");
        assertEq(newMetadata.placeOfWork, "");
        assertEq(newMetadata.contactInformation, 0);
        assertEq(newMetadata.salary, 0);
        assertEq(newMetadata.rating, 0);
        vm.expectRevert();
        employeesContract.tokenURI(0);
        vm.stopPrank();
    }

    function test__transfersCorrectly() public {
        vm.startPrank(mineContract);
        employeesContract.transferFrom(mineContract, admin, 0);
        vm.stopPrank();
        assert(employeesContract.ownerOf(0) == admin);
    }

    function test_baseURI() public {
        vm.startPrank(makeAddr("someAddress"));
        vm.expectRevert();
        employeesContract.setBaseURI("https://abc/");
        vm.stopPrank();
        vm.startPrank(admin);
        employeesContract.setBaseURI("https://abc/");
        vm.stopPrank();
        assertEq(employeesContract.tokenURI(0), "https://abc/skdjc");
    }
}
