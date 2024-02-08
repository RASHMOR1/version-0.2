// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBlockAbstract {
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

    event BlockAbstract__MinedPercentageUpdated(uint32 indexed minedPercentage);
    event BlockAbstract__CoordinatesChanged(int256 indexed x, int256 indexed y, int256 indexed z);
    event BlockAbstract__MotherBlocksPopulated();

    function changeReadinessStatus(ReadinessForMining newStatus) external;
    function manuallyChangeMinedPercentage(uint32 newMinedPercentage) external;
    function changeCoordinates(int256 new_x, int256 new_y, int256 new_z) external;
    function getBlockCoordinates() external view returns (int256, int256, int256);
}
