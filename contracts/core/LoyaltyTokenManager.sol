// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ServiceTokenManager} from "./../implementations/ServiceTokenManager.sol";
import {LoyaltyTokenAttributes} from "./../libraries/LoyaltyTokenAttributes.sol";
import {IDynamicToken} from "./../interfaces/IDynamicToken.sol";

contract LoyaltyTokenManager is ServiceTokenManager {
    error NotEnoughPoints();

    constructor(address loyaltyToken) ServiceTokenManager(loyaltyToken) {}

    function addPoints(
        uint tokenId,
        uint rootTokenId,
        address rootFatherAddress
    )
        external
        verifyRelationPermission(tokenId, rootTokenId, rootFatherAddress)
    {
        IDynamicToken dynamicToken = IDynamicToken(serviceTokenAddress);
        uint currentPoints = uint(
            dynamicToken.getTraitValue(
                tokenId,
                LoyaltyTokenAttributes.POINTS_ATTR
            )
        );

        super.setTrait(
            tokenId,
            LoyaltyTokenAttributes.POINTS_ATTR,
            bytes32(currentPoints + 1)
        );
    }

    function redeemPoints(
        uint tokenId,
        uint pointsToRedeem
    ) external tokenOwned(tokenId) {
        IDynamicToken dynamicToken = IDynamicToken(serviceTokenAddress);
        uint currentPoints = uint(
            dynamicToken.getTraitValue(
                tokenId,
                LoyaltyTokenAttributes.POINTS_ATTR
            )
        );
        if (pointsToRedeem > currentPoints) {
            revert NotEnoughPoints();
        }

        super.setTrait(
            tokenId,
            LoyaltyTokenAttributes.POINTS_ATTR,
            bytes32(currentPoints - pointsToRedeem)
        );
    }
}
