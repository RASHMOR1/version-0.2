// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract OreSlot {
    ////////////////////////////
    ///// Errors
    ////////////////////////////////

    error OreSlot__SlotHasNoOreOfThisQuality(uint256 quality);
    error OreSlot__NoVolumeInSlot();
    ////////////////////////////
    ///// Constants
    ////////////////////////////////

    uint256 public constant PRECISION = 10000;

    ////////////////////////////
    ///// State Variables
    ////////////////////////////////

    uint256[] public qualities; // all qualities of ore in this slot (ex. 15%, 20% , etc.)
    mapping(uint256 => bool) public isInQuality; // mapping to check if specified quality exists in this slot
    mapping(uint256 => uint256) public qualityToVolume; // volume of ore of specific quality
    uint256 public totalVolume; // total volume of ore in this slot
    AggregatorV3Interface internal priceFeed; // price feed address of this ore to get actual price of the ore

    ////////////////////////////
    ///// Events
    ////////////////////////////////
    event OreSlot__AddedNewVolume(uint256 indexed quality, uint256 indexed volume);

    ////////////////////////////
    ///// Public Functions
    ////////////////////////////////

    //this function sets price feed address that will be called to get actual price of the ore
    // this function is called on deployment stage
    function setPriceFeed(AggregatorV3Interface newPriceFeed) public {
        priceFeed = newPriceFeed;
    }

    // this function updates storage of this ore slot, adds volume to specified quality
    // if quality doesn't exist,function adds this quality and adds volume
    function addNewVolume(uint256 quality, uint256 volume) public {
        if (!isInQuality[quality]) {
            qualities.push(quality);
            isInQuality[quality] = true;
        }
        qualityToVolume[quality] += volume;
        totalVolume += volume;
        emit OreSlot__AddedNewVolume(quality, volume);
    }

    // implement oracle and calculate approximate $$ value of ore in this storage slot
    function getCurrentUSDValueOfOreInThisSlot() public view returns (uint256) {
        int256 currentPrice = getPrice();
        uint256 approximateOreVolume = getApproximateOreVolume();
        return uint256(currentPrice) * approximateOreVolume; // <---- must be adjusted according to price per what (t, kg...) and what is ore volume(t, kg...)
    }

    //this function represents moving ore from storage to processing plant
    // all ore data from this contract is cleared
    function moveToProcessingPlant() public {
        uint256[] memory copyQualities = qualities;
        if (copyQualities.length > 0) {
            for (uint256 i = 0; i < copyQualities.length; i++) {
                isInQuality[copyQualities[i]] = false;
                qualityToVolume[copyQualities[i]] = 0;
            }
            delete qualities;
            delete totalVolume;
        } else {
            revert OreSlot__NoVolumeInSlot();
        }
    }

    ////////////////////////////
    ///// View Functions
    ////////////////////////////////

    function getPrice() public view returns (int256) {
        (, int256 price,,,) = priceFeed.latestRoundData();
        return price;
    }

    // This function calculates the approximate total volume of ore in the slot.
    // It does this by iterating over all the qualities of ore present in the slot.
    // For each quality, it retrieves the volume of ore of that quality and divides it by the quality percentage.
    // This gives an approximation of the total volume of ore for that quality.
    // The function then sums up these volumes for all qualities to get the total approximate volume of ore in the slot.
    // This function is useful for getting a rough estimate of how much ore is in the slot, irrespective of its quality.

    function getApproximateOreVolume() public view returns (uint256) {
        uint256[] memory copyQualities = qualities;
        uint256 volumeSum;
        if (copyQualities.length > 0) {
            for (uint256 i = 0; i < copyQualities.length; i++) {
                uint256 volumeOfThisQuality = qualityToVolume[copyQualities[i]];
                uint256 oreVolume = (volumeOfThisQuality * copyQualities[i] * PRECISION) / 100;
                volumeSum += oreVolume;
            }
            return volumeSum;
        } else {
            revert OreSlot__NoVolumeInSlot();
        }
    }

    ////////////////////////////
    ///// View Functions
    ////////////////////////////////

    function getQualitiesLength() public view returns (uint256) {
        return qualities.length;
    }
}
