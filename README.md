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


