// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEmployeesContract {
    // Events
    event EmployeesContract__NewEmployeeCreated(uint256 indexed tokenId, address indexed to);
    event EmployeesContract__TokenMetadataUpdated(
        uint256 indexed tokenId, string newPosition, string placeOfWork, uint256 salary
    );
    event EmployeesContract__AddedNewTokenURI(uint256 indexed tokenId, string indexed tokenURI);
    event EmployeesContract__EmployeeFired(uint256 indexed tokenId);
    event EmployeesContract__BaseURIChanged(string indexed oldBaseURI, string indexed newBaseURI);

    // Structs
    struct ChangeableMetadata {
        string currentPosition;
        string placeOfWork;
        uint256 salary;
        uint256 contactInformation;
        uint256 rating;
    }

    // Functions
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function currentTokenId() external view returns (uint256);
    function tokenURI(uint256 tokenId) external view returns (string memory);
    function setBaseURI(string memory newBaseURI) external;
    function mint(
        address to,
        string calldata currentPosition,
        string calldata placeOfWork,
        uint256 contactInformation,
        uint128 salary,
        uint128 rating,
        string calldata _tokenURI
    ) external;
    function updateTokenMetadata(
        uint256 tokenId,
        string calldata newPosition,
        string calldata newPlaceOfWork,
        uint256 contactInformation,
        uint128 newSalary,
        uint128 rating
    ) external;
    function fireEmployee(uint256 tokenId) external;
    function getTokenMetadata(uint256 tokenId) external view returns (ChangeableMetadata memory);
}
