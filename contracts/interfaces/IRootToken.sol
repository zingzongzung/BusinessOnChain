// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IRootToken is IERC165 {
    function addManagedService(uint tokenId, address serviceAddress) external;

    function removeManagedService(
        uint tokenId,
        address serviceAddress
    ) external;

    function getServiceAddressByTokenAddress(
        address tokenAddress
    ) external returns (address serviceAddress);
}
