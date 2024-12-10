// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

library Constants {
    bytes32 public constant NAME_ATTR = bytes32(abi.encodePacked("Name"));
    bytes32 public constant POINTS_ATTR = bytes32(abi.encodePacked("Points"));
    bytes32 public constant FATHER_TOKEN_ID =
        bytes32(abi.encodePacked("Father Id"));
    bytes32 public constant FATHER_TOKEN_ADDRESS =
        bytes32(abi.encodePacked("Father Address"));
}
