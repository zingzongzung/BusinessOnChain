// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface INodeToken is IERC165 {
    function allowChildNodeManagement(
        uint tokenId,
        address serviceAddress
    ) external;

    function isManagingChildNode(
        uint tokenId,
        address serviceAddress
    ) external view returns (bool);
}
