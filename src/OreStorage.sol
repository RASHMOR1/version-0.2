// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IOreSlot} from "./Interfaces/IOreSlot.sol";

contract OreStorage {
    ////////////////////////////
    ///// Errors
    ////////////////////////////////

    error OreStorage__SlotDoesNotExist(uint256 slotNumber);
    ////////////////////////////
    ///// State Variables
    ////////////////////////////////

    uint256[] public storageSlots;
    uint256[] public qualities;
    mapping(uint256 => bool) public isInQuality;
    mapping(uint256 => uint256) public qualityToVolume;
    // uint256 is a number of slot and address is an address of a OreSlot smart-contract that will contain information about the volume of ore and its quality
    mapping(uint256 => address) public storageSlotsToAddress;
    address[] public storageSlotsAddresses;
    uint256 public totalVolumeInStorage;

    ////////////////////////////
    ///// Events
    ////////////////////////////////
    event OreStorage__OreSlotsPopulated();

    ////////////////////////////
    ///// Modifiers
    ////////////////////////////////

    modifier slotNumberExists(uint256 slotNumber) {
        if (slotNumber >= storageSlotsAddresses.length) {
            revert OreStorage__SlotDoesNotExist(slotNumber);
        }
        _;
    }

    ////////////////////////////
    ///// Public Functions
    ////////////////////////////////

    //this function interacts with storage slots and adds volume and quality information to this slots
    function addToStorage(uint256 slotNumber, uint256 addedVolume, uint256 addedQuality)
        public
        slotNumberExists(slotNumber)
    {
        IOreSlot(storageSlotsToAddress[slotNumber]).addNewVolume(addedQuality, addedVolume);
        totalVolumeInStorage += addedVolume;
    }

    //this function is to be called once during deploy. it populates storage slots addresses
    function populateOreStorage(address[] memory oreSlots) public {
        storageSlotsAddresses = oreSlots;
        for (uint256 i = 0; i < oreSlots.length; i++) {
            storageSlotsToAddress[i] = oreSlots[i];
        }
        emit OreStorage__OreSlotsPopulated();
    }

    ////////////////////////////
    ///// View Functions
    ////////////////////////////////

    function getTotalVolumeInStorage() public view returns (uint256) {
        return totalVolumeInStorage;
    }
}
