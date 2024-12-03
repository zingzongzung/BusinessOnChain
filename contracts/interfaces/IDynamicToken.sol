// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface IDynamicToken {
    function safeMint(
        address to,
        bytes32 imageId,
        bytes32[] memory attributes
    ) external returns (uint);

    function setTrait(
        uint256 tokenId,
        bytes32 traitKey,
        bytes32 newValue
    ) external;

    function getTraitValue(
        uint256 tokenId,
        bytes32 traitKey
    ) external view returns (bytes32 traitValue);
}
