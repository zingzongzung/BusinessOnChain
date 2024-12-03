// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

library LoyaltyTokenAttributes {
    bytes32 public constant NAME_ATTR = bytes32(abi.encodePacked("Name"));
    bytes32 public constant POINTS_ATTR = bytes32(abi.encodePacked("Points"));
}
