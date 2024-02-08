// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

import {IBlockAbstract} from "../Interfaces/IBlockAbstract.sol";

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract BlockAbstract {
    ////////////////////////////////
    ///// Errors
    ////////////////////////////////
    error BlockAbstract__CoordinatesOutOfBoundaries();
    error BlockAbstract__MinedPercentageOutOfBoundaries();

    ////////////////////////////////
    ///// Type Declarations
    ////////////////////////////////

    enum ReadinessForMining {
        NotDone,
        ReadyToBeDone,
        InProcessOfMining,
        Done
    }

    struct Coordinates {
        int256 x;
        int256 y;
        int256 z;
    }

    ////////////////////////////////
    ///// Constants
    ////////////////////////////////

    uint256 public constant PRECISION = 1000;

    ////////////////////////////////
    ///// State Variables
    ////////////////////////////////
    address public motherBlock; // block, that contains current block
    uint32 public minedPercentage; // percentage of the block that is already mined
    uint128 public blockRadius; // radius of the block

    ReadinessForMining public currentReadinessStatus;
    Coordinates public coordinates; // coordinates of the center of the block

    ////////////////////////////////
    ///// Events
    ////////////////////////////////

    event BlockAbstract__MinedPercentageUpdated(uint32 indexed minedPercentage);
    event BlockAbstract__CoordinatesChanged(int256 indexed x, int256 indexed y, int256 indexed z);
    event BlockAbstract__MotherBlocksPopulated();

    ////////////////////////////////
    ///// Modifiers
    ////////////////////////////////

    modifier isWithinTheBoundariesOfMotherBlock(int256 _x, int256 _y, int256 _z) {
        if (
            (_x < 0 && _x < int256(coordinates.x)) || (_x > 0 && _x > int256(coordinates.x))
                || (_y < 0 && _y < int256(coordinates.y)) || (_y > 0 && _y > int256(coordinates.y))
                || (_z < 0 && _z < int256(coordinates.z)) || (_z > 0 && _z > int256(coordinates.z))
        ) {
            revert BlockAbstract__CoordinatesOutOfBoundaries();
        }
        _;
    }

    modifier minedPercentageWithinBoundaries(uint32 newMinedPercentage) {
        if ((newMinedPercentage / PRECISION) > 100) {
            revert BlockAbstract__MinedPercentageOutOfBoundaries();
        }
        _;
    }

    ///////////////////////////////
    ///// Constructor
    ////////////////////////////////

    constructor(
        uint32 newMinedPercentage,
        ReadinessForMining currentStatus,
        int256 _x,
        int256 _y,
        int256 _z,
        address _motherBlock
    ) {
        minedPercentage = newMinedPercentage;
        currentReadinessStatus = currentStatus;
        coordinates = Coordinates(_x, _y, _z);
        motherBlock = _motherBlock;
    }

    ///////////////////////////////
    ///// Public Functions
    ////////////////////////////////

    function changeReadinessStatus(ReadinessForMining newStatus) public {
        currentReadinessStatus = newStatus;
    }

    function manuallyChangeMinedPercentage(uint32 newMinedPercentage)
        public
        minedPercentageWithinBoundaries(newMinedPercentage)
    {
        minedPercentage = newMinedPercentage;
        emit BlockAbstract__MinedPercentageUpdated(newMinedPercentage);
    }

    function changeCoordinates(int256 new_x, int256 new_y, int256 new_z) public {
        coordinates = Coordinates(new_x, new_y, new_z);
        emit BlockAbstract__CoordinatesChanged(new_x, new_y, new_z);
    }

    ///////////////////////////////
    ///// View Functions
    ////////////////////////////////

    function getBlockCoordinates() public view returns (int256, int256, int256) {
        return (coordinates.x, coordinates.y, coordinates.z);
    }
}
