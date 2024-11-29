// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import {IServiceToken} from "./../interfaces/IServiceToken.sol";
import {IEntityToken} from "./../interfaces/IEntityToken.sol";

abstract contract EntityToken is IEntityToken {
    using ERC165Checker for address;

    error NotAServiceTokenAddress();
    error ServiceTokenAlreadyRegistered();

    bytes4 public constant SERVICE_INTERFACE_ID =
        type(IServiceToken).interfaceId;

    mapping(uint => address[]) tokenRegisteredServices;

    //TODO Add validations of ownership plus token existance
    function addService(uint tokenId, address serviceAddress) public {
        if (!serviceAddress.supportsInterface(SERVICE_INTERFACE_ID)) {
            revert NotAServiceTokenAddress();
        }
        if (isAddressPresent(tokenId, serviceAddress)) {
            revert ServiceTokenAlreadyRegistered();
        }

        tokenRegisteredServices[tokenId].push(serviceAddress);
    }

    function isAddressPresent(
        uint256 key,
        address addr
    ) internal view returns (bool) {
        address[] memory addrArray = tokenRegisteredServices[key];
        for (uint256 i = 0; i < addrArray.length; i++) {
            if (addrArray[i] == addr) {
                return true;
            }
        }
        return false;
    }
}
