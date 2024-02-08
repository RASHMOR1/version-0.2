// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BlockAbstract} from "./Abstract/BlockAbstract.sol";

contract ContainingBlock is BlockAbstract {
    ////////////////////////////////
    ///// State Variables
    ////////////////////////////////

    address[] public daughterBlocks; // addresses of direct daughter blocks

    ////////////////////////////////
    ///// Events
    ////////////////////////////////

    event BlockAbstract__DaughterBlocksPopulated();

    constructor(
        uint32 newMinedPersentage,
        ReadinessForMining currentStatus,
        int256 _x,
        int256 _y,
        int256 _z,
        address _motherBlock
    ) BlockAbstract(newMinedPersentage, currentStatus, _x, _y, _z, _motherBlock) {}

    ///////////////////////////////
    ///// Public Functions
    ////////////////////////////////

    // this function will be called during deployment process to populate daughter blocks
    function populateDaughterBlocks(address[] memory newDaughterBlocks) public {
        daughterBlocks = newDaughterBlocks;
        emit BlockAbstract__DaughterBlocksPopulated();
    }

    // this function automatically calculates mined percentage of this block by retrieving mined percentages of daughter blocks and calculating average
    function automaticallyChangeMinedPercentage() public {
        address[] memory copyDaughterBlocks = daughterBlocks;
        uint256 percentageSum;
        for (uint256 i = 0; i < copyDaughterBlocks.length; i++) {
            percentageSum += BlockAbstract(copyDaughterBlocks[i]).minedPercentage();
        }
        uint256 newMinedPercentage = percentageSum / copyDaughterBlocks.length;
        minedPercentage = uint32(newMinedPercentage);
        emit BlockAbstract__MinedPercentageUpdated(minedPercentage);
    }

    ///////////////////////////////
    ///// View Functions
    ////////////////////////////////

    function getNumberOfDaughterBlocks() public view returns (uint256) {
        return daughterBlocks.length;
    }

    function getArrayOfDaughterBlocks() public view returns (address[] memory) {
        return daughterBlocks;
    }

    function getDaughterBlockByIndex(uint256 index) public view returns (address) {
        return address(daughterBlocks[index]);
    }
}
