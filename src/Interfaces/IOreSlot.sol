// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface IOreSlot {
    // State variables
    function PRECISION() external view returns (uint256);
    function qualities(uint256 index) external view returns (uint256);
    function isInQuality(uint256 quality) external view returns (bool);
    function qualityToVolume(uint256 quality) external view returns (uint256);
    function totalVolume() external view returns (uint256);

    // Events
    event OreSlot__AddedNewVolume(uint256 indexed quality, uint256 indexed volume);

    // Public Functions
    function setPriceFeed(AggregatorV3Interface newPriceFeed) external;
    function addNewVolume(uint256 quality, uint256 volume) external;
    function moveToProcessingPlant() external;

    //View Functions
    function getCurrentUSDValueOfOreInThisSlot() external view returns (uint256);
    function getPrice() external view returns (int256);
    function getApproximateOreVolume() external view returns (uint256);
    function getQualitiesLength() external view returns (uint256);
}
