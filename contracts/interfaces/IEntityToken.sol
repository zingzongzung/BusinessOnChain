// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IEntityToken is IERC165 {
    function addService(uint tokenId, address serviceAddress) external;

    function hasService(
        uint tokenId,
        address serviceAddress
    ) external view returns (bool);
}
