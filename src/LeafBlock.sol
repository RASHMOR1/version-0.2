// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BlockAbstract} from "./Abstract/BlockAbstract.sol";
import {IOreStorage} from "./Interfaces/IOreStorage.sol";

contract LeafBlock is BlockAbstract {
    ////////////////////////////////
    ///// State Variables
    ////////////////////////////////

    IOreStorage public storageContract; // address of the storage contract

    ////////////////////////////////
    ///// Events
    ////////////////////////////////

    event LeafBlock__TransferToStorageSlot(uint256 indexed slotNumber, uint256 indexed volume, uint256 indexed quality);
    ///////////////////////////////
    ///// Constructor
    ////////////////////////////////

    constructor(
        uint32 newMinedPersentage,
        ReadinessForMining currentStatus,
        int256 _x,
        int256 _y,
        int256 _z,
        address _motherBlock,
        IOreStorage _storageContract
    ) BlockAbstract(newMinedPersentage, currentStatus, _x, _y, _z, _motherBlock) {
        storageContract = _storageContract;
    }

    ///////////////////////////////
    ///// Public Functions
    ////////////////////////////////

    //this function interacts with storage slots through storage contract.  ore volume and its quality information is added to the specified slot
    function transferToStorageSlot(uint256 slotNumber, uint256 volume, uint256 quality) public {
        storageContract.addToStorage(slotNumber, volume, quality);
        emit LeafBlock__TransferToStorageSlot(slotNumber, volume, quality);
    }
}
