// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {NodeToken} from "./../implementations/NodeToken.sol";
import {IRootToken} from "./../interfaces/IRootToken.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {INodeService} from "./../interfaces/INodeService.sol";

abstract contract RootToken is IRootToken, NodeToken {
    using EnumerableSet for EnumerableSet.AddressSet;
    mapping(uint => EnumerableSet.AddressSet) private trackedServices;
    mapping(address => address) private serviceAddressByTokenAddress;

    constructor(
        address defaultAdmin,
        string memory name,
        string memory symbol
    ) NodeToken(defaultAdmin, name, symbol, true) {}

    function addManagedService(
        uint tokenId,
        address serviceAddress
    ) external onlyTokenOwned(tokenId, address(this)) {
        if (isManagingService(tokenId, serviceAddress)) {
            revert ServiceTokenAlreadyRegistered();
        }

        trackedServices[tokenId].add(serviceAddress);
        INodeService nodeService = INodeService(serviceAddress);
        address serviceTokenAddress = nodeService.getNodeTokenAddress();
        allowChildNodeManagement(tokenId, serviceTokenAddress);
        serviceAddressByTokenAddress[serviceTokenAddress] = serviceAddress;
    }

    function removeManagedService(
        uint tokenId,
        address serviceAddress
    ) external onlyTokenOwned(tokenId, address(this)) {
        if (serviceAddress == address(this)) {
            revert InvalidServiceNode();
        }

        if (!isManagingService(tokenId, serviceAddress)) {
            revert ServiceTokenNotRegistered();
        }

        trackedServices[tokenId].remove(serviceAddress);
        INodeService nodeService = INodeService(serviceAddress);
        address serviceTokenAddress = nodeService.getNodeTokenAddress();
        revokeChildNodeManagement(tokenId, serviceTokenAddress);
        serviceAddressByTokenAddress[serviceTokenAddress] = address(0);
    }

    function isManagingService(
        uint tokenId,
        address serviceAddress
    ) public view returns (bool) {
        return trackedServices[tokenId].contains(serviceAddress);
    }

    function getServiceAddressByTokenAddress(
        address tokenAddress
    ) external returns (address serviceAddress) {
        serviceAddress = serviceAddressByTokenAddress[tokenAddress];
    }
}
