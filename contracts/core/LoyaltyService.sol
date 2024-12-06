// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {LoyaltyTokenAttributes} from "./../libraries/LoyaltyTokenAttributes.sol";
import {IDynamicToken} from "./../interfaces/IDynamicToken.sol";
import {INodeService} from "./../interfaces/INodeService.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract LoyaltyService is INodeService {
    address private _loyaltyTokenAddress;

    address[] private registeredCollections;

    constructor(address loyaltyToken) {
        _loyaltyTokenAddress = loyaltyToken;
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
        multiplier = nftcollectionBalance < 10 ? 1 : nftcollectionBalance < 50
            ? 2
            : 3;
    }
}
