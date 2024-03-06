// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {EmployeesContract} from "../src/DynamicNFTs/EmployeesContract.sol";

contract DeployEmployeesContract is Script {
    EmployeesContract employeesContract;

    function run() public {
        vm.startBroadcast();

        employeesContract = new EmployeesContract();

        vm.stopBroadcast();
    }
}

// forge script script/DeployEmployeesContract.s.sol:DeployEmployeesContract --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv
