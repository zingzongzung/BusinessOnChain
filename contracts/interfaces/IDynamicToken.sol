// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface IDynamicToken {
    function safeMint(address to, bytes32[] memory attributes) external;
}
