# version-0.1

Version #0.1 of "Mining industry in blockchain" project


# Ore Block Management System

## Overview

In the ore mining industry, controlling the quality of ore is crucial for efficient resource extraction. To achieve this, ore bodies are divided into blocks, each containing information about the ore quality within that block. To enhance the accuracy of this information, blocks are further subdivided into smaller units called sub-blocks, which can then be divided into even smaller blocks. In this project, the smallest units of blocks are referred to as Leaf Blocks, while the larger blocks containing them are referred to as Containing Blocks (which can have child blocks).

The smart contracts representing these blocks (Containing Block, Leaf Block) will inherit from an abstract contract named BlockAbstract, which includes common functions for these smart contracts.

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

