// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IServiceToken} from "./../interfaces/IServiceToken.sol";
import {IProviderToken} from "./../interfaces/IProviderToken.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IDynamicToken} from "./../interfaces/IDynamicToken.sol";

abstract contract ServiceTokenManager {
    using ERC165Checker for address;

    struct Token {
        uint tokenId;
        address addressId;
    }

    error NotAnEntityTokenAddress();
    error ServiceNotAddedToThisEntity();
    error TokenNotOwned();
    error RelationPermissionNotPresent(uint);

    mapping(uint => Token) tokenRelations;

    bytes4 public constant ENTITY_INTERFACE_ID =
        type(IProviderToken).interfaceId;

    address serviceTokenAddress;

    constructor(address _serviceTokenAddress) {
        serviceTokenAddress = _serviceTokenAddress;
    }

    function safeMint(
        address to,
        bytes32[] memory attributes,
        uint nodeFatherId,
        address nodeFatherAddress
    ) public verifyCreatePermission(nodeFatherId, nodeFatherAddress) {
        IDynamicToken dynamicToken = IDynamicToken(serviceTokenAddress);
        dynamicToken.safeMint(to, attributes);
    }

    function createRelation(
        uint tokenId,
        uint tokenFatherId,
        address tokenFatherAddress
    ) internal verifyCreatePermission(tokenFatherId, tokenFatherAddress) {
        tokenRelations[tokenId] = Token(tokenFatherId, tokenFatherAddress);
    }

    modifier verifyRelationPermission(
        uint tokenId,
        uint tokenFatherId,
        address tokenFatherAddress
    ) {
        if (
            tokenRelations[tokenId].tokenId != tokenFatherId ||
            tokenRelations[tokenId].addressId != tokenFatherAddress
        ) {
            revert RelationPermissionNotPresent(tokenId);
        }
        _;
    }

    modifier verifyCreatePermission(
        uint tokenFatherId,
        address tokenFatherAddress
    ) {
        if (!tokenFatherAddress.supportsInterface(ENTITY_INTERFACE_ID)) {
            revert NotAnEntityTokenAddress();
        }

        IProviderToken entityToken = IProviderToken(tokenFatherAddress);
        if (!entityToken.hasService(tokenFatherId, serviceTokenAddress)) {
            revert ServiceNotAddedToThisEntity();
        }

        IERC721 nftToken = IERC721(tokenFatherAddress);
        if (nftToken.ownerOf(tokenFatherId) != msg.sender) {
            revert TokenNotOwned();
        }

        _;
    }
}
