// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {LeafBlock} from "../../src/LeafBlock.sol";
import {BlockAbstract} from "../../src/Abstract/BlockAbstract.sol";
import {OreStorage} from "../../src/OreStorage.sol";
import {OreSlot} from "../../src/OreSlot.sol";
import {IOreStorage} from "../../src/Interfaces/IOreStorage.sol";
import {MockV3Aggregator} from "./mocks/MockV3Aggregator.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract TestOreSlot is Test {
    OreSlot oreSlot;
    MockV3Aggregator mockAggregator;
    uint256 public PRECISION;
    uint256 public quality1 = 23;
    uint256 public quality2 = 15;
    uint256 public volume1 = 13454;
    uint256 public volume2 = 100000;
    uint256 public mockPrice = 1000;

    event OreSlot__AddedNewVolume(uint256 indexed quality, uint256 indexed volume);

    function setUp() public {
        oreSlot = new OreSlot();
        mockAggregator = new MockV3Aggregator(18, int256(mockPrice));
        oreSlot.setPriceFeed(AggregatorV3Interface(address(mockAggregator)));
        PRECISION = oreSlot.PRECISION();
    }

    modifier addedOre() {
        oreSlot.addNewVolume(quality1, volume1);
        oreSlot.addNewVolume(quality2, volume2);
        _;
    }

    function test__AddNewVolume() public {
        vm.expectEmit(true, true, false, true);
        emit OreSlot__AddedNewVolume(quality1, volume1);
        oreSlot.addNewVolume(quality1, volume1);
        oreSlot.addNewVolume(quality2, volume2);
        assert(oreSlot.totalVolume() == volume1 + volume2);
        assert(oreSlot.qualities(0) == quality1);
        assert(oreSlot.qualities(1) == quality2);
        assert(oreSlot.isInQuality(quality1));
        assert(oreSlot.isInQuality(quality2));
        assert(oreSlot.qualityToVolume(quality1) == volume1);
        assert(oreSlot.qualityToVolume(quality2) == volume2);
    }

    function test__GetPrice() public {
        int256 price = oreSlot.getPrice();
        assertEq(price, int256(mockPrice));
    }

    function test__GetApproximateVolume() public addedOre {
        uint256 value = oreSlot.getApproximateOreVolume();
        uint256 expectedValue1 = (volume1 * quality1 * PRECISION) / 100;
        uint256 expectedValue2 = (volume2 * quality2 * PRECISION) / 100;
        assertEq(value, (expectedValue1 + expectedValue2));
    }

    function test__GetApproximateVolume2() public {
        vm.expectRevert(OreSlot.OreSlot__NoVolumeInSlot.selector);
        oreSlot.getApproximateOreVolume();
    }

    function test__GetCurrentUSDValueOfOre() public addedOre {
        uint256 currentUSDValue = oreSlot.getCurrentUSDValueOfOreInThisSlot();
        uint256 currentVolume = oreSlot.getApproximateOreVolume();
        int256 orePrice = oreSlot.getPrice();
        uint256 expectedUSDValue = currentVolume * uint256(orePrice);
        assertEq(currentUSDValue, expectedUSDValue);
    }

    function test__moveToProcessingPlant() public addedOre {
        oreSlot.moveToProcessingPlant();
        assert(oreSlot.getQualitiesLength() == 0);
        assert(oreSlot.isInQuality(0) == false);
        assert(oreSlot.isInQuality(1) == false);
        assert(oreSlot.qualityToVolume(0) == 0);
        assert(oreSlot.qualityToVolume(1) == 0);
        assert(oreSlot.totalVolume() == 0);
    }
}
