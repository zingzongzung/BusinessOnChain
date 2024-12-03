// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IProviderToken} from "./../interfaces/IProviderToken.sol";
import {IServiceToken} from "./../interfaces/IServiceToken.sol";
import {DynamicToken} from "./../abstract/DynamicToken.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

abstract contract ProviderToken is IProviderToken, ERC165, DynamicToken {
    error ServiceTokenAlreadyRegistered();
    error NotAServiceTokenAddress();
    error TokenNotOwned();

    using ERC165Checker for address;

    bytes4 public constant SERVICE_INTERFACE_ID =
        type(IServiceToken).interfaceId;

    mapping(uint => address[]) tokenRegisteredServices;

    constructor(
        address defaultAdmin,
        string memory name,
        string memory symbol
    ) DynamicToken(defaultAdmin, name, symbol) {}

    function addService(uint tokenId, address serviceAddress) external {
        if (!serviceAddress.supportsInterface(SERVICE_INTERFACE_ID)) {
            revert NotAServiceTokenAddress();
        }

        IERC721 nftToken = IERC721(address(this));
        if (nftToken.ownerOf(tokenId) != msg.sender) {
            revert TokenNotOwned();
        }

        if (isAddressPresent(tokenId, serviceAddress)) {
            revert ServiceTokenAlreadyRegistered();
        }

        tokenRegisteredServices[tokenId].push(serviceAddress);
    }

    function hasService(
        uint tokenId,
        address serviceAddress
    ) external view returns (bool) {
        return isAddressPresent(tokenId, serviceAddress);
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

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC165, IERC165, DynamicToken)
        returns (bool)
    {
        return
            interfaceId == type(IProviderToken).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
