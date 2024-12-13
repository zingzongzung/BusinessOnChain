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
        string memory name,
        string memory symbol
    ) NodeToken(name, symbol, true) {}

    function safeMint(
        address to,
        bytes32 _tokenImageId,
        bytes32[] memory attributeValues
    ) external virtual {
        require(isRootNodeToken, "This token can't be minted as root level ");
        internalSafeMint(to, _tokenImageId, attributeValues);
    }

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
        if (serviceTokenAddress != address(0)) {
            allowChildNodeManagement(tokenId, serviceTokenAddress);
        }

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

    function getManagedServices(
        uint tokenId
    ) external view returns (address[] memory managedServices) {
        uint256 setLength = trackedServices[tokenId].length();
        managedServices = new address[](setLength);

        for (uint256 i = 0; i < setLength; i++) {
            managedServices[i] = trackedServices[tokenId].at(i);
        }
    }

    function isManagingService(
        uint tokenId,
        address serviceAddress
    ) public view returns (bool) {
        return trackedServices[tokenId].contains(serviceAddress);
    }

    function getServiceAddressByTokenAddress(
        address tokenAddress
    ) external view returns (address serviceAddress) {
        serviceAddress = serviceAddressByTokenAddress[tokenAddress];
    }
}
