// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IOreStorage {
    // State variables
    function storageSlots(uint256 index) external view returns (uint256);
    function qualities() external view returns (uint256);
    function isInQuality(uint256 quality) external view returns (bool);
    function qualityToVolume(uint256 quality) external view returns (uint256);
    function storageSlotsToAddress(uint256 index) external view returns (address);
    function storageSlotsAddresses(uint256 index) external view returns (address);
    function totalVolumeInStorage() external view returns (uint256);

    // Events
    event OreStorage__OreSlotsPopulated();

    // Public Functions
    function addToStorage(uint256 slotNumber, uint256 addedVolume, uint256 addedQuality) external;
    function populateOreStorage(address[] calldata oreSlots) external;

    //View Functions
    function getTotalVolumeInStorage() external view returns (uint256);
}
