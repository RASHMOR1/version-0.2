// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

// Each employee will be depicted as a dynamic NFT. Immutable parameters will be stored in the tokenURI (IPFS link), while mutable ones will be kept in storage.

//Unchangeable:
// 1. Date of Birth
// 2. Name
// 3. Surname
// 4. Image ( photo of an employee)
// 5. Gender
// 6. Date of Hire(the day employee started working for the company)

// Changeable
// 1. currentPosition(Ex driver, miner, CEO , etc)
// 2. placeOfWork(name of mine)
// 3. salary
// 4. contact information
// 5. rating (lets say there will be a rating for each employee )

///CRITICAL NOTICE!!!!
// The receiver address (i.e., mine smart contract) must invoke the setApprovalForAll function with the address of this contract's owner.
// This is necessary to enable this contract to burn tokens (i.e., fire employees).

contract EmployeesContract is ERC721, ERC721Enumerable, Ownable {
    error EmployeesContract__NotAllowedToPerformThisAction();
    error EmployeesContract__TokenIdDoesNotExist();

    uint256 public currentTokenId;
    string private currentBaseURI;

    struct ChangeableMetadata {
        string currentPosition;
        string placeOfWork;
        uint256 contactInformation;
        uint128 salary;
        uint128 rating;
    }

    // mapping , where changeable metadata is stored
    mapping(uint256 => ChangeableMetadata) private tokenMetadata;

    // Implementing a standard IPFS system here is not feasible.
    // This is because, when a new employee is added, we would need to include this new employee in the off-chain data structure, store it on IPFS, and then modify the base URI in this contract.
    // This approach does not appear to be reliable.
    // Therefore, it seems that the best solution is to use a mapping with individual IPFS links.

    mapping(uint256 => string) private tokenURIs;

    //events
    event EmployeesContract__NewEmployeeCreated(uint256 indexed tokenId, address indexed to);
    event EmployeesContract__TokenMetadataUpdated(
        uint256 indexed tokenId, string currentPosition, string placeOfWork, uint256 salary
    );
    event EmployeesContract__AddedNewTokenURI(uint256 indexed tokenId, string indexed tokenURI);
    event EmployeesContract__EmployeeFired(uint256 indexed tokenId);
    event EmployeesContract__BaseURIChanged(string indexed oldBaseURI, string indexed newBaseURI);

    //modifiers
    modifier onlyCurrentOwner(uint256 tokenId) {
        if (ownerOf(tokenId) != msg.sender && owner() != msg.sender && !isApprovedForAll(ownerOf(tokenId), msg.sender))
        {
            revert EmployeesContract__NotAllowedToPerformThisAction();
        }
        _;
    }

    constructor() ERC721("Employees", "EMPL") Ownable(msg.sender) {}

    // overrides for enumerable
    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    // override for ERC721

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        string memory baseURI = _baseURI();

        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenURIs[tokenId]) : "";
    }

    function _baseURI() internal view override returns (string memory) {
        return currentBaseURI;
    }
    // main contract logic

    //function to set baseURI or change baseURI

    function setBaseURI(string memory newBaseURI) public onlyOwner {
        string memory oldBaseURI = currentBaseURI;
        currentBaseURI = newBaseURI;
        emit EmployeesContract__BaseURIChanged(oldBaseURI, newBaseURI);
    }

    // This function is responsible for creating a new employee NFT.
    // It mints a new NFT to a specified address and updates the tokenMetadata and tokenURIs data structures accordingly.
    // Opting to use _mint instead of safeMint because it’s an onlyOwner function.
    // The owner is aware of the exact addresses of mine contract and is unlikely to make a mistake.
    // Therefore, there’s no need for an additional check to see if the recipient’s smart contract can handle the NFT.
    // This approach also helps in saving gas costs.

    function mint(
        address to,
        string memory currentPosition,
        string memory placeOfWork,
        uint256 contactInformation,
        uint128 salary,
        uint128 rating,
        string memory _tokenURI
    ) public onlyOwner {
        uint256 tokenId = currentTokenId;
        tokenMetadata[tokenId] = ChangeableMetadata(currentPosition, placeOfWork, contactInformation, salary, rating);
        tokenURIs[tokenId] = _tokenURI;
        currentTokenId++;
        _mint(to, tokenId);
        emit EmployeesContract__NewEmployeeCreated(tokenId, to);
    }

    // function to update changeable metadata
    // can be performed by owner or mine addresses
    function updateTokenMetadata(
        uint256 tokenId,
        string memory newPosition,
        string memory newPlaceOfWork,
        uint256 contactInformation,
        uint128 newSalary,
        uint128 rating
    ) public onlyCurrentOwner(tokenId) {
        if (tokenId >= currentTokenId) {
            revert EmployeesContract__TokenIdDoesNotExist();
        }
        tokenMetadata[tokenId] = ChangeableMetadata(newPosition, newPlaceOfWork, contactInformation, newSalary, rating);
        emit EmployeesContract__TokenMetadataUpdated(tokenId, newPosition, newPlaceOfWork, newSalary);
    }

    // This function is used to terminate an employee's contract.
    // It does this by transferring the associated employee NFT to a null address and subsequently erasing its token data from the tokenMetadata and tokenURIs structures.

    function fireEmployee(uint256 tokenId) public {
        _update(address(0), tokenId, _msgSender());
        delete tokenMetadata[tokenId];
        delete tokenURIs[tokenId];
        emit EmployeesContract__EmployeeFired(tokenId);
    }

    // private internal functions

    function getTokenMetadata(uint256 tokenId) public view returns (ChangeableMetadata memory) {
        return tokenMetadata[tokenId];
    }
}
