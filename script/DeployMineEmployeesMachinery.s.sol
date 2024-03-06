// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {MineContract} from "../src/MineContract.sol";
import {MachineryAndEquipmentContract} from "../src/DynamicNFTs/MachineryAndEquipmentContract.sol";
import {EmployeesContract} from "../src/DynamicNFTs/EmployeesContract.sol";

contract DeployMineEmployeesAndMachineryContracts is Script {
    MineContract mineContract;
    MachineryAndEquipmentContract machineryAndEquipmentContract;
    EmployeesContract employeesContract;
    address[] mineAddreses;

    function run() public {
        vm.startBroadcast();

        mineContract = new MineContract();
        mineAddreses.push(address(mineContract));
        machineryAndEquipmentContract = new MachineryAndEquipmentContract();
        employeesContract = new EmployeesContract();
        mineContract.setEmployeesContractAddress(address(employeesContract));
        mineContract.setMachineryAndEquipmentContractAddress(address(machineryAndEquipmentContract));
        mineContract.setApprovalForAllEmployees(msg.sender, true);
        mineContract.setApprovalForAllMachinery(msg.sender, true);

        vm.stopBroadcast();
    }
}
