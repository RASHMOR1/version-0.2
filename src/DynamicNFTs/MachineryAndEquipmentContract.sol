// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// The same system for mutable and not immutable metadata as in EmployeesContract

// Unchangeable:
// 1 Model Number: The unique identifier or model number of the machinery or equipment.
// 2 Manufacturer: The company or entity that produced the machinery.
// 3 Operating Voltage: The voltage required for operation (if applicable).
// 4 Power Rating: The power output or consumption (in watts or kilowatts).
// 5 Weight: The weight of the machinery or equipment.
// 6 Dimensions: Length, width, and height.
// 7 Material Composition: The primary materials used in construction (e.g., steel, aluminum, plastic).
// 8 Capacity: Maximum load capacity, production capacity, or throughput.
// 9 Speed: Operational speed (e.g., rotations per minute, meters per second).
// 10 Temperature Range: The range of temperatures the machinery can operate within.
// 11 Pressure Rating: If applicable, the maximum pressure the equipment can handle.
// 12 Maintenance Schedule: Recommended maintenance intervals or procedures.
// 13 User Manual or Documentation: Links to user manuals or technical documentation.
// 14 Image

// Changeable
// 1 Year of Manufacture: The year when the machinery was built.
// 2 Serial Number: A unique serial number assigned to each unit.
// 3 Machinery Condition: Condition of a vehicle.

///CRITICAL NOTICE!!!!
// The receiver address (i.e., mine smart contract) must invoke the setApprovalForAll function with the address of this contract's owner.
// This is necessary to enable this contract to burn tokens (i.e., decommission machinery).

contract MachineryAndEquipmentContract is ERC721, ERC721Enumerable, Ownable {
    using Strings for uint256;

    error MachineryAndEquipmentContract__NotAllowedToPerformThisAction();
    error MachineryAndEquipment__TokenIdDoesNotExist(uint256 tokenId);

    struct ChangeableMetadata {
        uint16 yearOfManufacture;
        uint8 machineryCondition; // this number represents condition of a vehicle from 0 to 100, where 100 is "fully functional, like new", and 0 is "not functional". condition is decided by chief mechanic
        uint256 serialNumber;
    }

    address[] public minesAddresses;
    uint256 public currentTokenId;
    string private currentBaseURI;

    mapping(uint256 => uint256) public tokenIdToVehicleModel;
    mapping(uint256 => ChangeableMetadata) private tokenMetadata;

    mapping(address => bool) public addressesAllowedToRepairMachinery;

    //events
    event MachineryAndEquipmentContract__MachineryRepair(
        uint256 indexed tokenId, uint8 indexed machineryCondition, string mechanicsMessage
    );
    event MachineryAndEquipment__MachineryDecommission(uint256 indexed tokenId);
    event MachineryAndEquipment__ChangedAllowedToRepairMachinery(address indexed mechanicAddress, bool indexed permit);
    event MachineryAndEquipment__MinesAddresesAdded();
    event MachineryAndEquipment__NewMachineryOrEquipmentCreated(uint256 indexed tokenId, address indexed reciever);
    event MachineryAndEquipment__BaseURIChanged(string indexed oldBaseURI, string indexed newBaseURI);
    //modifiers

    modifier allowedToRepair(address user) {
        if (!addressesAllowedToRepairMachinery[user]) {
            revert MachineryAndEquipmentContract__NotAllowedToPerformThisAction();
        }
        _;
    }

    modifier isMine(address user) {
        address[] memory copyMinesAddresses = minesAddresses;
        bool found;

        for (uint256 i = 0; i < copyMinesAddresses.length; i++) {
            if (user == copyMinesAddresses[i]) {
                found = true;
                break;
            }
        }
        if (!found) {
            revert MachineryAndEquipmentContract__NotAllowedToPerformThisAction();
        }
        _;
    }

    modifier onlyCurrentOwner(uint256 tokenId) {
        if (ownerOf(tokenId) != msg.sender && owner() != msg.sender && !isApprovedForAll(ownerOf(tokenId), msg.sender))
        {
            revert MachineryAndEquipmentContract__NotAllowedToPerformThisAction();
        }
        _;
    }

    modifier tokenIdExists(uint256 tokenId) {
        if (tokenId >= currentTokenId) {
            revert MachineryAndEquipment__TokenIdDoesNotExist(tokenId);
        }
        _;
    }

    constructor() ERC721("MachineryAndEquipment", "MaE") Ownable(msg.sender) {}

    // overrides for ERC721Enumerable
    function _increaseBalance(address account, uint128 value) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // This function overrides the ERC721 tokenURI function.
    // In the classical ERC721 implementation, each NFT's metadata is accessed individually using its tokenId.
    // However, in this case, we don't need to store metadata for all vehicles individually because vehicles of the same model share unchangeable parameters.
    // Instead, we store the parameters of different vehicle models on IPFS, and each tokenId is linked to the corresponding model through the tokenIdToVehicleModel mapping.
    // For example, if there are three vehicles of the same model, each will have its own tokenId, but they will share the same unchangeable metadata (stored in tokenURI).

    // IMPORTANT!
    // If you choose to add new vehicle models, create new IPFS entries and update the base URI.
    // Ensure that you maintain the initial order of models and append new models at the end.
    // Failing to do so will disrupt the mapping tokenIdToVehicleModel.

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenIdToVehicleModel[tokenId].toString()) : "";
    }

    function _baseURI() internal view override returns (string memory) {
        return currentBaseURI;
    }

    // main functions

    //function to set baseURI or change baseURI

    function setBaseURI(string memory newBaseURI) public onlyOwner {
        string memory oldBaseURI = currentBaseURI;
        currentBaseURI = newBaseURI;
        emit MachineryAndEquipment__BaseURIChanged(oldBaseURI, newBaseURI);
    }

    // Opting to use _mint instead of safeMint because it’s an onlyOwner function.
    // The owner is aware of the exact addresses of mine contract and is unlikely to make a mistake.
    // Therefore, there’s no need for an additional check to see if the recipient’s smart contract can handle the NFT.
    // This approach also helps in saving gas costs.

    function mint(
        address to,
        uint16 yearOfManufacture,
        uint8 machineryCondition,
        uint256 serialNumber,
        uint256 vehicleModel
    ) public onlyOwner {
        uint256 tokenId = currentTokenId;
        tokenMetadata[tokenId] = ChangeableMetadata(yearOfManufacture, machineryCondition, serialNumber);
        tokenIdToVehicleModel[tokenId] = vehicleModel;
        currentTokenId++;
        _mint(to, tokenId);
        emit MachineryAndEquipment__NewMachineryOrEquipmentCreated(tokenId, to);
    }

    // This function is called by mechanics to record machinery repairs.
    // The mechanic sets the new vehicle condition, and an associated message describing the issue is emitted.
    // To view the service history, an off-chain listener should be set up to record the MachineryAndEquipmentContract__MachineryRepair event.

    function makeRepairsToMachinery(uint256 tokenId, string memory someMessageFromMechanic, uint8 newMachineryCondition)
        public
        allowedToRepair(msg.sender)
        tokenIdExists(tokenId)
    {
        tokenMetadata[tokenId].machineryCondition = newMachineryCondition;
        emit MachineryAndEquipmentContract__MachineryRepair(tokenId, newMachineryCondition, someMessageFromMechanic);
    }

    // This function is designed to decommission unused machinery.
    // It achieves this by transferring the corresponding vehicle NFT to a null address and subsequently removing its tokenId from storage structures.

    function decommissionMachinery(uint256 tokenId) public tokenIdExists(tokenId) onlyCurrentOwner(tokenId) {
        _update(address(0), tokenId, _msgSender());
        delete tokenIdToVehicleModel[tokenId];
        delete tokenMetadata[tokenId];
        emit MachineryAndEquipment__MachineryDecommission(tokenId);
    }

    // set functions

    // this function can only be called by mines smart contracts and it sets mechanics addresses (addresses that are allowed to call makeRepairsToMachinery)
    function setAllowedToRepair(address user, bool permit) public isMine(msg.sender) {
        addressesAllowedToRepairMachinery[user] = permit;
        emit MachineryAndEquipment__ChangedAllowedToRepairMachinery(user, permit);
    }

    //this function fills mines addresses for isMine modifier
    function fillMineAddresses(address[] memory _minesAddresses) public onlyOwner {
        minesAddresses = _minesAddresses;
        emit MachineryAndEquipment__MinesAddresesAdded();
    }

    // get functions

    function getTokenMetadata(uint256 tokenId) public view returns (ChangeableMetadata memory) {
        return tokenMetadata[tokenId];
    }
}
