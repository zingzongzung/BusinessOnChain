// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IDynamicToken} from "./../interfaces/IDynamicToken.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

abstract contract DynamicToken is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    AccessControl,
    IDynamicToken
{
    using Strings for uint256;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 private _nextTokenId;
    mapping(uint => uint) tokenURIVersion;
    bytes32[] baseTokenAttributes;
    bytes32[] tokenAttributes;

    mapping(uint => bytes32) tokenImageId;

    mapping(uint256 tokenId => mapping(bytes32 traitKey => bytes32 traitValue)) _traits;

    string _traitMetadataURI;

    error InvalidNumberOfAttributes();

    constructor(
        address defaultAdmin,
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }

    function grantMintRole(
        address minter
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(MINTER_ROLE, minter);
    }

    function _setTokenAttributes(bytes32[] memory attributes) internal {
        tokenAttributes = attributes;
    }

    function _addBaseTokenAddtribute(bytes32 attribute) internal {
        baseTokenAttributes.push(attribute);
    }

    function getTokenAttributes() external view returns (bytes32[] memory) {
        return concatenate(baseTokenAttributes, tokenAttributes);
    }

    function concatenate(
        bytes32[] memory array1,
        bytes32[] memory array2
    ) internal pure returns (bytes32[] memory) {
        bytes32[] memory result = new bytes32[](array1.length + array2.length);

        for (uint i = 0; i < array1.length; i++) {
            result[i] = array1[i];
        }

        for (uint j = 0; j < array2.length; j++) {
            result[array1.length + j] = array2[j];
        }

        return result;
    }

    function _updateTokenURI(uint tokenId) internal {
        tokenURIVersion[tokenId]++;
        _setTokenURI(
            tokenId,
            string(
                abi.encodePacked(
                    tokenId.toString(),
                    "/V",
                    tokenURIVersion[tokenId].toString()
                )
            )
        );
    }

    function _baseImageURI() internal view virtual returns (string memory);

    function imageURI(uint256 tokenId) public view returns (string memory) {
        return string(abi.encodePacked(_baseImageURI(), tokenImageId[tokenId]));
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function internalSafeMint(
        address to,
        bytes32 _tokenImageId,
        bytes32[] memory attributeValues
    ) internal returns (uint tokenId) {
        tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        initTraits(tokenId, attributeValues);
        tokenImageId[tokenId] = _tokenImageId;
        tokenURIVersion[tokenId] = 0;
        _updateTokenURI(tokenId);
    }

    function initTraits(
        uint256 tokenId,
        bytes32[] memory attributeValues
    ) internal {
        if (attributeValues.length != tokenAttributes.length) {
            revert InvalidNumberOfAttributes();
        }

        for (uint index = 0; index < tokenAttributes.length; index++) {
            _setTrait(tokenId, tokenAttributes[index], attributeValues[index]);
        }
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    error TraitValueUnchanged();

    /**
     * @notice Get the value of a trait for a given token ID.
     * @param tokenId The token ID to get the trait value for
     * @param traitKey The trait key to get the value of
     */
    function getTraitValue(
        uint256 tokenId,
        bytes32 traitKey
    ) public view virtual returns (bytes32 traitValue) {
        // Return the trait value.
        return _traits[tokenId][traitKey];
    }

    /**
     * @notice Get the values of traits for a given token ID.
     * @param tokenId The token ID to get the trait values for
     * @param traitKeys The trait keys to get the values of
     */
    function getTraitValues(
        uint256 tokenId,
        bytes32[] calldata traitKeys
    ) public view virtual returns (bytes32[] memory traitValues) {
        // Set the length of the traitValues return array.
        uint256 length = traitKeys.length;
        traitValues = new bytes32[](length);

        // Assign each trait value to the corresopnding key.
        for (uint256 i = 0; i < length; ) {
            bytes32 traitKey = traitKeys[i];
            traitValues[i] = getTraitValue(tokenId, traitKey);
            unchecked {
                ++i;
            }
        }
    }

    function setTrait(
        uint256 tokenId,
        bytes32 traitKey,
        bytes32 newValue
    ) internal virtual {
        // Revert if the new value is the same as the existing value.
        bytes32 existingValue = _traits[tokenId][traitKey];
        if (existingValue == newValue) {
            revert TraitValueUnchanged();
        }

        // Set the new trait value.
        _setTrait(tokenId, traitKey, newValue);

        //Update the Token URI
        _updateTokenURI(tokenId);
    }

    /**
     * @notice Set the trait value (without emitting an event).
     * @param tokenId The token ID to set the trait value for
     * @param traitKey The trait key to set the value of
     * @param newValue The new trait value to set
     */
    function _setTrait(
        uint256 tokenId,
        bytes32 traitKey,
        bytes32 newValue
    ) internal virtual {
        // Set the new trait value.
        _traits[tokenId][traitKey] = newValue;
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721, ERC721Enumerable, ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
