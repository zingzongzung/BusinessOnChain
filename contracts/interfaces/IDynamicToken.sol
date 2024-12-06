// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface IDynamicToken {
    function getTraitValue(
        uint256 tokenId,
        bytes32 traitKey
    ) external view returns (bytes32 traitValue);
}
