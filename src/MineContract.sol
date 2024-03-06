// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IEmployeesContract} from "./Interfaces/IEmployeeContract.sol";
import {IMachineryAndEquipmentContract} from "./Interfaces/IMachineryAndEquipment.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MineContract is Ownable {
    error MineContract__EmployeeOrNachineryDoesNotExist();

    address public employeesContractAddress;
    address public machineryAndEquipmentContractAddress;

    // Mapping from employee token ID to their personal address.
    mapping(uint256 => address) public employeeTokenIdToTheirPersonalAddress;

    // Mapping from employee token ID to machinery token ID.
    mapping(uint256 => uint256) public employeeTokenIdToMachineryTokenId;

    event MineContract__EmployeeAssignedToMachinery(uint256 indexed employeeTokenId, uint256 indexed machineryTokenId);
    event MineContract__EmployeeWasAssignedPersonalAddress(uint256 indexed tokenId, address indexed personalAddress);
    event MineContract__EmployeesContractAddressChanged(address indexed previous, address indexed current);
    event MineContract__MachineryAndEquipmentContractAddressChanged(address indexed previous, address indexed current);

    modifier employeeExists(uint256 employeeTokenId) {
        uint256 currentEmployeeId = IEmployeesContract(employeesContractAddress).currentTokenId();
        if (currentEmployeeId < employeeTokenId) {
            revert MineContract__EmployeeOrNachineryDoesNotExist();
        }
        _;
    }

    modifier machineryExists(uint256 machineryTokenId) {
        uint256 currentMachineryId =
            IMachineryAndEquipmentContract(machineryAndEquipmentContractAddress).currentTokenId();
        if (currentMachineryId < machineryTokenId) {
            revert MineContract__EmployeeOrNachineryDoesNotExist();
        }
        _;
    }

    constructor() Ownable(msg.sender) {}

    // Function to transfer a machinery token from this contract to another address.
    // For example to another mine
    function transferMachinery(uint256 tokenId, address to) public onlyOwner {
        IMachineryAndEquipmentContract machineryContractAddress =
            IMachineryAndEquipmentContract(machineryAndEquipmentContractAddress);
        machineryContractAddress.safeTransferFrom(address(this), to, tokenId);
    }

    // Function to transfer an employee token from this contract to another address.
    function transferEmployee(uint256 tokenId, address to) public onlyOwner {
        IEmployeesContract employeeContractAddress = IEmployeesContract(employeesContractAddress);
        employeeContractAddress.safeTransferFrom(address(this), to, tokenId);
    }

    function assignEmployeeToMachinery(uint256 employeeTokenId, uint256 machineryTokenId)
        public
        employeeExists(employeeTokenId)
        machineryExists(machineryTokenId)
        onlyOwner
    {
        employeeTokenIdToMachineryTokenId[employeeTokenId] = machineryTokenId;
        emit MineContract__EmployeeAssignedToMachinery(employeeTokenId, machineryTokenId);
    }

    // Each employee possesses a unique personal address, which grants them permissions to modify certain aspects of the contract where permitted.
    // For instance, the personal addresses of mechanics are authorized to alter the 'machineryCondition' parameter in the dynamic NFTs of MachineryAndEquipment.
    function assignEmployeeHisPersonalAddress(uint256 tokenId, address personalAddress)
        public
        employeeExists(tokenId)
        onlyOwner
    {
        employeeTokenIdToTheirPersonalAddress[tokenId] = personalAddress;
        emit MineContract__EmployeeWasAssignedPersonalAddress(tokenId, personalAddress);
    }

    // set functions

    function setEmployeesContractAddress(address _newAddress) public onlyOwner {
        address previousAddress = employeesContractAddress;
        employeesContractAddress = _newAddress;
        emit MineContract__EmployeesContractAddressChanged(previousAddress, _newAddress);
    }

    function setMachineryAndEquipmentContractAddress(address _newAddress) public onlyOwner {
        address previousAddress = machineryAndEquipmentContractAddress;
        machineryAndEquipmentContractAddress = _newAddress;
        emit MineContract__MachineryAndEquipmentContractAddressChanged(previousAddress, _newAddress);
    }

    // Functions that interact with dynamic NFT contracts

    // This function invokes the setAllowedToRepair method in the MachineryAndEquipmentContract.
    // It adds the individual addresses of mechanics, thereby granting them the ability to modify the 'machinery condition' parameter in the dynamic NFT of the machinery.
    // Additionally, by setting the 'permit' parameter to false, it can also revoke these permissions, disallowing mechanics from making changes.

    function setAllowedToRepair(address user, bool permit) public onlyOwner {
        IMachineryAndEquipmentContract(machineryAndEquipmentContractAddress).setAllowedToRepair(user, permit);
    }

    // This function invokes the fireEmployee method in the EmployeesContract
    function fireEmployee(uint256 tokenId) public onlyOwner {
        IEmployeesContract(employeesContractAddress).fireEmployee(tokenId);
    }

    // This function invokes decomissionMachinery method in MachineryAndEquipmentContract
    function decomissionMachinery(uint256 tokenId) public onlyOwner {
        IMachineryAndEquipmentContract(machineryAndEquipmentContractAddress).decommissionMachinery(tokenId);
    }

    // This function invokes updateTokenMetadata method in the EmployeesContract
    function changeEmployeeMetadata(
        uint256 tokenId,
        string memory newPosition,
        string memory newPlaceOfWork,
        uint256 contactInformation,
        uint128 newSalary,
        uint128 rating
    ) public onlyOwner {
        IEmployeesContract(employeesContractAddress).updateTokenMetadata(
            tokenId, newPosition, newPlaceOfWork, contactInformation, newSalary, rating
        );
    }

    // Functions to permit trusted addresses to manage machinery and employees NFTs on behalf of mineContract

    function setApprovalForAllMachinery(address operator, bool approved) public onlyOwner {
        IMachineryAndEquipmentContract(machineryAndEquipmentContractAddress).setApprovalForAll(operator, approved);
    }

    function setApprovalForAllEmployees(address operator, bool approved) public onlyOwner {
        IEmployeesContract(employeesContractAddress).setApprovalForAll(operator, approved);
    }
}
