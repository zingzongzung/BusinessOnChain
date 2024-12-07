// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {LoyaltyTokenAttributes} from "./../libraries/LoyaltyTokenAttributes.sol";
import {IDynamicToken} from "./../interfaces/IDynamicToken.sol";
import {INodeService} from "./../interfaces/INodeService.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract LoyaltyService is INodeService, AccessControl {
    address private _loyaltyTokenAddress;

    address[] private registeredCollections;

    struct LoyaltyPrize {
        //Use a set here instead
        uint id;
        bytes32 prizeName;
        uint points;
    }

    mapping(address => mapping(uint => LoyaltyPrize[])) asf;

    constructor(address defaultAdmin, address loyaltyToken) {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _loyaltyTokenAddress = loyaltyToken;
    }

    function addCollection(
        address tokenCollection
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        registeredCollections.push(tokenCollection);
    }

    function getNodeTokenAddress()
        external
        view
        returns (address loyaltyToken)
    {
        loyaltyToken = _loyaltyTokenAddress;
    }

    function getLoyaltyTokenMultiplier(
        address loyaltyTokenOwner
    ) external view returns (uint multiplier) {
        multiplier = 0;
        for (uint i = 0; i < registeredCollections.length; i++) {
            multiplier += getLoyaltyTokenMultiplierPerNFTCollection(
                loyaltyTokenOwner,
                registeredCollections[i]
            );
        }
    }

    function getLoyaltyTokenMultiplierPerNFTCollection(
        address loyaltyTokenOwner,
        address nftAddress
    ) internal view returns (uint multiplier) {
        IERC721 nftCollection = IERC721(nftAddress);
        uint nftcollectionBalance = nftCollection.balanceOf(loyaltyTokenOwner);
        multiplier = nftcollectionBalance <= 3 ? 1 : nftcollectionBalance <= 10
            ? 2
            : 3;
    }
}
