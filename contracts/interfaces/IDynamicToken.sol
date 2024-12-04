// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface IDynamicToken {
    function setTrait(
        uint256 tokenId,
        bytes32 traitKey,
        bytes32 newValue
    ) external;

    function getTraitValue(
        uint256 tokenId,
        bytes32 traitKey
    ) external view returns (bytes32 traitValue);

    function safeMint(
        address to,
        bytes32 _tokenImageId,
        bytes32[] memory attributeValues
    ) external returns (uint tokenId);
}
