// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {INodeToken} from "./../interfaces/INodeToken.sol";
import {DynamicToken} from "./../abstract/DynamicToken.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

abstract contract NodeToken is INodeToken, DynamicToken, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using ERC165Checker for address;

    error NotANodeToken();
    error TokenNotOwned();
    error InvalidFatherNode();
    error NodeNotRegisteredOnFather();
    error ServiceTokenAlreadyRegistered();
    error InvalidServiceNode();
    error ServiceTokenNotRegistered();

    bool isRootNodeToken;

    struct Token {
        uint tokenId;
        address addressId;
    }

    mapping(uint => EnumerableSet.AddressSet) managedChildNodes;

    //mapping of the father node to the given node token id
    mapping(uint => Token) fatherNode;

    bytes4 public constant I_NODE_TOKEN_INTERFACE_ID =
        type(INodeToken).interfaceId;

    constructor(
        address defaultAdmin,
        string memory name,
        string memory symbol,
        bool _isRootNodeToken
    ) DynamicToken(defaultAdmin, name, symbol) Ownable(msg.sender) {
        isRootNodeToken = _isRootNodeToken;
    }

    function setFatherManagedTrait(
        uint256 tokenId,
        bytes32 traitKey,
        bytes32 newValue,
        uint nodeFatherId,
        address nodeFatherAddress
    )
        internal
        onlyFatherNode(tokenId, nodeFatherId, nodeFatherAddress)
        onlyTokenOwned(nodeFatherId, nodeFatherAddress)
    {
        setTrait(tokenId, traitKey, newValue);
    }

    function setOwnerManagedTrait(
        uint256 tokenId,
        bytes32 traitKey,
        bytes32 newValue
    ) internal virtual onlyTokenOwned(tokenId, address(this)) {
        setTrait(tokenId, traitKey, newValue);
    }

    modifier onlyFatherNode(
        uint tokenId,
        uint tokenFatherId,
        address tokenFatherAddress
    ) {
        if (
            fatherNode[tokenId].tokenId != tokenFatherId ||
            fatherNode[tokenId].addressId != tokenFatherAddress
        ) {
            revert InvalidFatherNode();
        }
        _;
    }

    modifier onlyTokenOwned(uint tokenId, address tokenAddress) {
        IERC721 nftToken = tokenAddress == address(this)
            ? this
            : IERC721(tokenAddress);
        if (nftToken.ownerOf(tokenId) != msg.sender) {
            revert TokenNotOwned();
        }
        _;
    }

    modifier onlyRegisteredFatherNode(
        uint tokenFatherId,
        address tokenFatherAddress
    ) {
        if (!tokenFatherAddress.supportsInterface(I_NODE_TOKEN_INTERFACE_ID)) {
            revert NotANodeToken();
        }

        INodeToken entityToken = INodeToken(tokenFatherAddress);
        if (!entityToken.isManagingChildNode(tokenFatherId, address(this))) {
            revert NodeNotRegisteredOnFather();
        }

        IERC721 nftToken = IERC721(tokenFatherAddress);
        if (nftToken.ownerOf(tokenFatherId) != msg.sender) {
            revert TokenNotOwned();
        }

        _;
    }

    function allowChildNodeManagement(
        uint tokenId,
        address nodeTokenAddress
    ) internal onlyTokenOwned(tokenId, address(this)) {
        if (!nodeTokenAddress.supportsInterface(I_NODE_TOKEN_INTERFACE_ID)) {
            revert NotANodeToken();
        }

        if (nodeTokenAddress == address(this)) {
            revert InvalidServiceNode();
        }

        if (isManagingChildNode(tokenId, nodeTokenAddress)) {
            revert ServiceTokenAlreadyRegistered();
        }

        managedChildNodes[tokenId].add(nodeTokenAddress);
    }

    function revokeChildNodeManagement(
        uint tokenId,
        address nodeTokenAddress
    ) internal onlyTokenOwned(tokenId, address(this)) {
        if (!nodeTokenAddress.supportsInterface(I_NODE_TOKEN_INTERFACE_ID)) {
            revert NotANodeToken();
        }

        if (nodeTokenAddress == address(this)) {
            revert InvalidServiceNode();
        }

        if (!isManagingChildNode(tokenId, nodeTokenAddress)) {
            revert ServiceTokenNotRegistered();
        }

        managedChildNodes[tokenId].remove(nodeTokenAddress);
    }

    function isManagingChildNode(
        uint tokenId,
        address nodeTokenAddress
    ) public view returns (bool) {
        return managedChildNodes[tokenId].contains(nodeTokenAddress);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, DynamicToken) returns (bool) {
        return
            interfaceId == type(INodeToken).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
