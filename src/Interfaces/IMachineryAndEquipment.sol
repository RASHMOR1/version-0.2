// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IMachineryAndEquipmentContract {
    // Events
    event MachineryAndEquipmentContract__MachineryRepair(
        uint256 indexed tokenId, uint8 indexed machineryCondition, string mechanicsMessage
    );
    event MachineryAndEquipment__MachineryDecommission(uint256 indexed tokenId);
    event MachineryAndEquipment__ChangedAllowedToRepairMachinery(address indexed mechanicAddress, bool indexed permit);
    event MachineryAndEquipment__MinesAddresesAdded();
    event MachineryAndEquipment__NewMachineryOrEquipmentCreated(uint256 indexed tokenId, address indexed reciever);
    event MachineryAndEquipment__BaseURIChanged(string indexed oldBaseURI, string indexed newBaseURI);

    // Structs
    struct ChangeableMetadata {
        uint16 yearOfManufacture;
        uint8 machineryCondition;
        uint256 serialNumber;
    }

    // Functions
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function currentTokenId() external view returns (uint256);
    function tokenURI(uint256 tokenId) external view returns (string memory);
    function setBaseURI(string memory newBaseURI) external;
    function mint(
        address to,
        uint16 yearOfManufacture,
        uint8 machineryCondition,
        uint256 serialNumber,
        uint256 vehicleModel
    ) external;
    function makeRepairsToMachinery(
        uint256 tokenId,
        string calldata someMessageFromMechanic,
        uint8 newMachineryCondition
    ) external;
    function decommissionMachinery(uint256 tokenId) external;
    function setAllowedToRepair(address user, bool permit) external;
    function fillMineAddresses(address[] memory _minesAddresses) external;
    function addressesAllowedToRepairMachinery(address user) external view returns (bool);
    function minesAddresses(uint256 index) external view returns (address);
    function tokenIdToVehicleModel(uint256 tokenId) external view returns (uint256);
    function getTokenMetadata(uint256 tokenId) external view returns (ChangeableMetadata memory);
}
