// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ContainingBlock} from "../../src/ContainingBlock.sol";
import {BlockAbstract} from "../../src/Abstract/BlockAbstract.sol";

contract TestContainingBlock is Test {
    ContainingBlock containingBlock;
    address[] public newArray;

    event BlockAbstract__MinedPercentageUpdated(uint32 indexed newMinedPercentage);
    event BlockAbstract__DaughterBlocksPopulated();

    uint256 public PRECISION;

    function setUp() public {
        containingBlock =
            new ContainingBlock(32, BlockAbstract.ReadinessForMining.ReadyToBeDone, 566, -2342, 3, address(0));
        PRECISION = containingBlock.PRECISION();
    }

    function test__ConstructorIsCorrect() public view {
        (int256 x, int256 y, int256 z) = containingBlock.getBlockCoordinates();
        assert(containingBlock.minedPercentage() == 32);
        assert(containingBlock.currentReadinessStatus() == BlockAbstract.ReadinessForMining.ReadyToBeDone);
        assert(x == 566);
        assert(y == -2342);
        assert(z == 3);
    }

    function test__ChangeReadinessStatus() public {
        containingBlock.changeReadinessStatus(BlockAbstract.ReadinessForMining.Done);
        assert(containingBlock.currentReadinessStatus() == BlockAbstract.ReadinessForMining.Done);
    }

    function test__ManuallyChangedMinedPercentage() public {
        uint32 newMinedPercentage = 1345;
        vm.expectEmit(true, false, false, true);
        emit BlockAbstract__MinedPercentageUpdated(newMinedPercentage);
        containingBlock.manuallyChangeMinedPercentage(newMinedPercentage);
        assertEq(containingBlock.minedPercentage(), newMinedPercentage);
    }

    function testFuzz__ModifierMinedPercentageWithinBoundaries(uint256 newMinedPercentage) public {
        newMinedPercentage = bound(newMinedPercentage, 0, 100000);
        containingBlock.manuallyChangeMinedPercentage(uint32(newMinedPercentage));
    }

    function test__ChangeCoordinates() public {
        int256 _x = 1111;
        int256 _y = -1111;
        int256 _z = -1114351;
        containingBlock.changeCoordinates(_x, _y, _z);
        (int256 x, int256 y, int256 z) = containingBlock.getBlockCoordinates();
        assertEq(x, _x);
        assertEq(y, _y);
        assertEq(z, _z);
    }

    function test__PopulateDaughterBlock() public {
        for (uint256 i = 0; i < 5; i++) {
            newArray.push(address(uint160(i)));
        }
        vm.expectEmit(false, false, false, false);
        emit BlockAbstract__DaughterBlocksPopulated();
        containingBlock.populateDaughterBlocks(newArray);
        for (uint256 i = 0; i < newArray.length; i++) {
            assert(containingBlock.daughterBlocks(i) == newArray[i]);
        }
        assert(containingBlock.getNumberOfDaughterBlocks() == newArray.length);
        assert(containingBlock.getDaughterBlockByIndex(1) == newArray[1]);
    }
}
