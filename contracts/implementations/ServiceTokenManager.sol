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

    error NotAProviderToken();
    error ServiceNotAddedToThisEntity();
    error TokenNotOwned();
    error RelationPermissionNotPresent(uint);

    address serviceTokenAddress;
    mapping(uint => Token) tokenRelations;

    bytes4 public constant PROVIDER_TOKEN_INTEFACE_ID =
        type(IProviderToken).interfaceId;

    constructor(address _serviceTokenAddress) {
        serviceTokenAddress = _serviceTokenAddress;
    }

    function setTrait(
        uint256 tokenId,
        bytes32 traitKey,
        bytes32 newValue
    ) internal {
        IDynamicToken serviceToken = IDynamicToken(serviceTokenAddress);
        serviceToken.setTrait(tokenId, traitKey, newValue);
    }

    function safeMint(
        address to,
        bytes32 _imageId,
        bytes32[] memory attributes,
        uint nodeFatherId,
        address nodeFatherAddress
    ) external verifyCreatePermission(nodeFatherId, nodeFatherAddress) {
        IDynamicToken serviceToken = IDynamicToken(serviceTokenAddress);
        uint tokenId = serviceToken.safeMint(to, _imageId, attributes);
        createRelation(tokenId, nodeFatherId, nodeFatherAddress);
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

    modifier tokenOwned(uint tokenId) {
        IERC721 nftToken = IERC721(serviceTokenAddress);
        if (nftToken.ownerOf(tokenId) != msg.sender) {
            revert TokenNotOwned();
        }
        _;
    }

    modifier verifyCreatePermission(
        uint tokenFatherId,
        address tokenFatherAddress
    ) {
        if (!tokenFatherAddress.supportsInterface(PROVIDER_TOKEN_INTEFACE_ID)) {
            revert NotAProviderToken();
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
