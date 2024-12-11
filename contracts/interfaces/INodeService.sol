// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface INodeService {
    function getNodeTokenAddress() external view returns (address tokenAddress);
}
