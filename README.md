# version-0.1

Version #0.1 of "Mining industry in blockchain" project

# Ore Block Management System

## Overview

In the ore mining industry, controlling the quality of ore is crucial for efficient resource extraction. To achieve this, ore bodies are divided into blocks, each containing information about the ore quality within that block. To enhance the accuracy of this information, blocks are further subdivided into smaller units called sub-blocks, which can then be divided into even smaller blocks. In this project, the smallest units of blocks are referred to as Leaf Blocks, while the larger blocks containing them are referred to as Containing Blocks (which can have child blocks).

The smart contracts representing these blocks (Containing Block, Leaf Block) will inherit from an abstract contract named BlockAbstract, which includes common functions for these smart contracts.
![image](https://github.com/RASHMOR1/version-0.1/assets/91812990/9409148a-7eb3-488c-8e52-3bbbff9433b6)

### BlockAbstract Contract

#### Variables:

- **MotherBlock:** Address of the parent block's smart contract.
- **MinedPercentage:** Indicates the percentage of the block that has been mined.
- **BlockRadius:** Radius of the block.
- **CurrentReadinessStatus:** Represents the stage of mining completion of the block (Not Done, Ready To Be Done, In Process Of Mining, Done).
- **Coordinates:** Coordinates of the center of the block (x, y, z).

#### Functions:

- **changeReadinessStatus:** Change the mining completion stage of the block.
- **manuallyChangeMinedPercentage:** Manually update the mined percentage.
- **changeCoordinates:** Update the coordinates of the block.
- **getBlockCoordinates:** View function to retrieve the coordinates of the block.

### Containing Block Contract

#### Variables:

- **daughterBlocks:** Array of addresses of daughter block smart contracts.

#### Functions:

- **populateDaughterBlocks:** Populate the array with daughter block addresses.
- **automaticallyChangeMinedPercentage:** Calculate the mined percentage by looping through daughter blocks, retrieving their mined percentage, and calculating the average.
- **getNumberOfDaughterBlocks:** Retrieve the number of daughter blocks.
- **getArrayOfDaughterBlocks:** Return the array of daughter block addresses.
- **getDaughterBlockByIndex:** Get the address of a daughter block by index in the daughterBlocks array.

### Leaf Block Contract

#### Variables:

- **storageContract:** Address of the storage contract.

#### Functions:

- **transferToStorageSlot:** Interact with the storage contract to add volume and quality information about ore from this block to a specified slot in the storage contract.

  ![image](https://github.com/RASHMOR1/version-0.1/assets/91812990/015c65b4-61c1-4997-ab64-a1e199422910)

### OreStorage Contract

The OreStorage contract represents a repository for storing mined ore. Each storage slot is managed by a corresponding OreSlot contract. Only Leaf Block contracts can interact with the OreStorage contract.

#### Variables:

- **storageSlots:** Array of addresses of oreSlot contracts for this storage.
- **qualities:** Array of qualities present in this storage.
- **isInQuality:** Mapping of quality to boolean indicating presence in this storage.
- **qualityToVolume:** Mapping of quality to volume of ore for that quality in this storage.
- **storageSlotsToAddress:** Mapping of slot number to its corresponding contract address.
- **storageSlotsAddresses:** Array of addresses of slots in this storage.
- **totalVolumeInStorage:** Total volume of ore in this storage.

#### Functions:

- **addToStorage:** Interacts with storage slots to add volume and quality information.
- **populateOreStorage:** Populates storage slot addresses during deployment.

### OreSlot Contract

The OreSlot contract represents an individual storage slot for ore. It manages the volume and quality of ore stored in that slot.

#### Variables:

- **qualities:** Array of qualities present in this slot.
- **isInQuality:** Mapping of quality to boolean indicating presence in this slot.
- **qualityToVolume:** Mapping of quality to volume of ore for that quality in this slot.
- **totalVolume:** Total volume of ore in this slot.
- **priceFeed:** Address of the oracle providing the price feed for ore.

#### Functions:

- **setPriceFeed:** Set the price feed oracle address.
- **addNewVolume:** Update the storage of this ore slot by adding volume to a specified quality.
- **getCurrentUSDValueOfOreInThisSlot:** Calculate the approximate USD value of ore in this slot using the oracle.
- **moveToProcessingPlant:** Move ore from storage to processing plant and clear all ore data from this contract.
- **getPrice:** Get the current price of ore from the oracle.
- **getApproximateOreVolume:** Calculate the approximate total volume of ore in this slot.
- **getQualitiesLength:** Return the number of qualities in this slot.

# Version 0.2 changes

## Employees, Machinery, and Equipment

These are represented by dynamic Non-Fungible Tokens (NFTs) with both mutable and immutable parameters. Immutable parameters are stored in the InterPlanetary File System (IPFS), while mutable parameters are stored in contract storage.

### Employees

**Immutable Parameters:**

- Date of Birth
- Name
- Surname
- Image (employee’s photo)
- Gender
- Date of Hire (the day the employee started working for the company)

**Mutable Parameters:**

- Current Position (e.g., driver, miner, CEO)
- Place of Work (name of the mine)
- Salary
- Contact Information
- Rating (a rating system for each employee)

### Machinery and Equipment

**Immutable Parameters:**

- Model Number
- Manufacturer
- Operating Voltage
- Power Rating
- Weight
- Dimensions
- Material Composition
- Capacity
- Speed
- Temperature Range
- Pressure Rating
- Maintenance Schedule
- User Manual or Documentation
- Image

**Mutable Parameters:**

- Year of Manufacture
- Machinery Condition
- Serial Number

![image](https://github.com/RASHMOR1/version-0.2/assets/91812990/122e6caa-083a-4bc4-9480-72241b86b4d6)


## EmployeesContract Contract

In this contract, each NFT (employee) has unique immutable parameters. Implementing a standard IPFS system here is not feasible because when a new employee is added, we would need to include this new employee in the off-chain data structure, store it on IPFS, and then modify the base URI in this contract. This approach does not appear to be reliable. Therefore, the best solution is to use a mapping with individual IPFS links.

### Variables

- **currentTokenId**: A counter for generating unique token IDs for newly minted employee NFTs.
- **currentBaseURI**: The current base URI used to generate token URIs.
- **tokenMetadata**: A mapping storing mutable metadata of each employee NFT.
- **tokenURIs**: A mapping storing the IPFS links (without baseURI) for the token URIs of each employee NFT.

### Functions

- **setBaseURI**: Allows the contract owner to set or change the base URI used for generating token URIs.
- **mint**: Allows the contract owner to mint a new employee NFT and assign it to a specific address with associated metadata and token URI.
- **updateTokenMetadata**: Allows the contract owner or authorized addresses to update the mutable metadata of an employee NFT.
- **fireEmployee**: Allows the contract owner to terminate an employee’s contract by burning their associated NFT.
- **getTokenMetadata**: Retrieves the mutable metadata of an employee NFT by its token ID.

## MachineryAndEquipmentContract Contract

In the classical ERC721 implementation, each NFT’s metadata is accessed individually using its tokenId. However, in this case, we don’t need to store metadata for all vehicles individually because vehicles of the same model share unchangeable parameters. Instead, we store the parameters of different vehicle models on IPFS, and each tokenId is linked to the corresponding model through the tokenIdToVehicleModel mapping. For example, if there are three vehicles of the same model, each will have its own tokenId, but they will share the same unchangeable metadata (stored in tokenURI).

### Variables

- **currentTokenId**: A counter for generating unique token IDs for newly minted machinery or equipment NFTs.
- **currentBaseURI**: The current base URI used to generate token URIs.
- **minesAddresses**: An array storing the addresses of mine contracts for use in access control.
- **addressesAllowedToRepairMachinery**: A mapping indicating whether an address is permitted to perform machinery repairs.
- **tokenMetadata**: A mapping storing mutable metadata of each machinery or equipment NFT.
- **tokenIdToVehicleModel**: A mapping linking each token ID to a vehicle model for accessing unchangeable metadata stored on IPFS.

### Functions

- **setBaseURI**: Allows the contract owner to set or change the base URI used for generating token URIs.
- **mint**: Allows the contract owner to mint a new machinery or equipment NFT and assign it to a specific address with associated metadata and token URI.
- **makeRepairsToMachinery**: Allows addresses permitted to repair machinery to record repairs and update the machinery’s condition.
- **decommissionMachinery**: Allows the contract owner to decommission unused machinery by burning its associated NFT.
- **setAllowedToRepair**: Allows mine contracts to set addresses permitted to repair machinery.
- **fillMineAddresses**: Allows the contract owner to populate the array of mine addresses.
- **getTokenMetadata**: Retrieves the mutable metadata of a machinery or equipment NFT by its token ID.

## MineContract Contract

MineContract represents the mine, stores the addresses of the Employees and Machinery and Equipment contracts and interacts with them. It keeps track of each employee’s personal address and the machinery they are assigned to, effectively encapsulating the entire operation of the mine within the blockchain. This includes the management of personnel, machinery, and equipment, making it a comprehensive representation of the mine’s operational structure.

### Variables

- **employeesContractAddress**: Stores the address of the EmployeesContract.
- **machineryAndEquipmentContractAddress**: Stores the address of the MachineryAndEquipmentContract.
- **employeeTokenIdToTheirPersonalAddress**: A mapping from an employee token ID to their personal address.
- **employeeTokenIdToMachineryTokenId**: A mapping from an employee token ID to a machinery token ID.

### Functions

- **transferMachinery**: Transfers a machinery token from this contract to another address.
- **transferEmployee**: Transfers an employee token from this contract to another address.
- **assignEmployeeToMachinery**: Assigns an employee to a specific piece of machinery by updating the mapping.
- **assignEmployeeHisPersonalAddress**: Assigns a personal address to an employee, granting them permissions to modify certain aspects of the contract.
- **setEmployeesContractAddress**: Sets the address of the EmployeesContract.
- **setMachineryAndEquipmentContractAddress**: Sets the address of the MachineryAndEquipmentContract.
- **setAllowedToRepair**: Grants or revokes permissions for a user to repair machinery.
- **fireEmployee**: Terminates an employee's contract.
- **decomissionMachinery**: Decommissions unused machinery.
- **changeEmployeeMetadata**: Updates mutable metadata of an employee.
- **setApprovalForAllMachinery**: Sets approval for all machinery tokens for a specific operator.
- **setApprovalForAllEmployees**: Sets approval for all employee tokens for a specific operator.

## Updates from version 0.1

Three new Smart Contracts have been introduced in this update:

1. **Mine contract**: This contract symbolizes the mine and encapsulates its operations.
2. **EmployeesContract**: This contract represents all employees as dynamic NFTs, each with their unique attributes and parameters.
3. **MachineryAndEquipmentContract**: This contract signifies all machinery and equipment as dynamic NFTs, each with their specific characteristics.

## Version 0.3 Plans

1. **Automated Updates**: Implement functionality to automatically update `currentReadinessStatus` and `minedPercentage` in all `containingBlocks` when `LeafBlocks` are mined.

2. **MineContract enhancement**: Work on expanding the functionality of the MineContract. This could involve the addition of new functions that could provide more comprehensive management of the mine’s operations, such as advanced tracking of resources.

3. **Code Refactoring**: Conduct a comprehensive code review and refactor for improved readability, efficiency, and maintainability.
