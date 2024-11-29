// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IERC7496} from "./../interfaces/IERC7496.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

library DynamicTokenStorage {
    struct Layout {
        /// @dev A mapping of token ID to a mapping of trait key to trait value.
        mapping(uint256 tokenId => mapping(bytes32 traitKey => bytes32 traitValue)) _traits;
        /// @dev An offchain string URI that points to a JSON file containing trait metadata.
        string _traitMetadataURI;
    }

    function layout(
        bytes32 storage_slot
    ) internal pure returns (Layout storage l) {
        assembly {
            l.slot := storage_slot
        }
    }
}

/**
 * @title EntityToken
 *
 * @dev Implementation of [ERC-7496](https://eips.ethereum.org/EIPS/eip-7496) Dynamic Traits.
 * Uses a storage layout pattern for upgradeable contracts.
 *
 * Requirements:
 * - Overwrite `setTrait` with access role restriction.
 * - Expose a function for `setTraitMetadataURI` with access role restriction if desired.
 */
abstract contract DynamicToken is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    AccessControl,
    IERC7496
{
    using Strings for uint256;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 private _nextTokenId;
    mapping(uint => uint) tokenURIVersion;
    mapping(uint => bytes32[]) tokenAttributes;
    bytes32 internal STORAGE_SLOT;

    constructor(
        address defaultAdmin,
        address minter,
        string memory name,
        string memory symbol,
        string memory storage_slot_name
    ) ERC721(name, symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
        STORAGE_SLOT = keccak256(abi.encodePacked(storage_slot_name));
    }

    function _setTokenAttributes(
        uint tokenId,
        bytes32[] memory attributes
    ) internal {
        tokenAttributes[tokenId] = attributes;
    }

    function getTokenAttributes(
        uint tokenId
    ) external view returns (bytes32[] memory attributes) {
        return tokenAttributes[tokenId];
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

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function safeMint(
        address to,
        bytes32[] memory attributes
    ) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenAttributes(tokenId, attributes);
        _updateTokenURI(tokenId);
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

    using DynamicTokenStorage for DynamicTokenStorage.Layout;

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
        return
            DynamicTokenStorage.layout(STORAGE_SLOT)._traits[tokenId][traitKey];
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

    /**
     * @notice Get the URI for the trait metadata
     */
    function getTraitMetadataURI()
        external
        view
        virtual
        returns (string memory labelsURI)
    {
        // Return the trait metadata URI.
        //return DynamicTokenStorage.layout()._traitMetadataURI;
        return
            "https://zzo.outsystemscloud.com/IPFSOutsystems/rest/MetadataURI/EntityTokenMetadataURI";
    }

    /**
     * @notice Set the value of a trait for a given token ID.
     *         Reverts if the trait value is unchanged.
     * @dev    IMPORTANT: Override this method with access role restriction.
     * @param tokenId The token ID to set the trait value for
     * @param traitKey The trait key to set the value of
     * @param newValue The new trait value to set
     */
    function setTrait(
        uint256 tokenId,
        bytes32 traitKey,
        bytes32 newValue
    ) public virtual {
        // Revert if the new value is the same as the existing value.
        bytes32 existingValue = DynamicTokenStorage
            .layout(STORAGE_SLOT)
            ._traits[tokenId][traitKey];
        if (existingValue == newValue) {
            revert TraitValueUnchanged();
        }

        // Set the new trait value.
        _setTrait(tokenId, traitKey, newValue);

        //Update the Token URI
        _updateTokenURI(tokenId);

        // Emit the event noting the update.
        emit TraitUpdated(traitKey, tokenId, newValue);
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
        DynamicTokenStorage.layout(STORAGE_SLOT)._traits[tokenId][
            traitKey
        ] = newValue;
    }

    /**
     * @notice Set the URI for the trait metadata.
     * @param uri The new URI to set.
     */
    function _setTraitMetadataURI(string memory uri) internal virtual {
        // Set the new trait metadata URI.
        DynamicTokenStorage.layout(STORAGE_SLOT)._traitMetadataURI = uri;

        // Emit the event noting the update.
        emit TraitMetadataURIUpdated();
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721, ERC721Enumerable, ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return
            super.supportsInterface(interfaceId) ||
            interfaceId == type(IERC7496).interfaceId;
    }
}
