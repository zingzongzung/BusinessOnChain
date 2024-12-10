// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IRootToken} from "./../interfaces/IRootToken.sol";
import {LoyaltyService} from "./LoyaltyService.sol";
import {ChildToken} from "./../implementations/ChildToken.sol";
import {Constants} from "./../libraries/Constants.sol";

contract LoyaltyToken is ChildToken {
    error NotEnoughPoints();

    constructor(
        address defaultAdmin
    ) ChildToken(defaultAdmin, "LoyaltyToken", "LTK") {
        bytes32[] memory attributes = new bytes32[](2);
        attributes[0] = Constants.NAME_ATTR;
        attributes[1] = Constants.POINTS_ATTR;
        _setTokenAttributes(attributes);
    }

    function addPoints(
        uint tokenId,
        uint rootTokenId,
        address fatherAddress
    ) external {
        uint currentPoints = uint(
            getTraitValue(tokenId, Constants.POINTS_ATTR)
        );

        IRootToken fatherToken = IRootToken(fatherAddress);
        LoyaltyService loyaltyService = LoyaltyService(
            fatherToken.getServiceAddressByTokenAddress(address(this))
        );
        uint extraPoints = loyaltyService.getLoyaltyTokenMultiplier(
            ownerOf(tokenId)
        );
        super.setFatherManagedTrait(
            tokenId,
            Constants.POINTS_ATTR,
            bytes32(currentPoints + 1 + extraPoints),
            rootTokenId,
            fatherAddress
        );
    }

    function redeemPoints(uint tokenId, uint pointsToRedeem) external {
        uint currentPoints = uint(
            getTraitValue(tokenId, Constants.POINTS_ATTR)
        );
        if (pointsToRedeem > currentPoints) {
            revert NotEnoughPoints();
        }

        setOwnerManagedTrait(
            tokenId,
            Constants.POINTS_ATTR,
            bytes32(currentPoints - pointsToRedeem)
        );
    }

    /**
     * address(this).toHexString() when replacing gettoken by actual address and make it trully dinamic
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return
            "https://personal-ixqe4210.outsystemscloud.com/BusinessOnChain_API/rest/Token/GetLoyaltyTokenURI/";
    }

    function _baseImageURI()
        internal
        view
        virtual
        override
        returns (string memory)
    {
        return
            "https://personal-ixqe4210.outsystemscloud.com/BusinessOnChain_API/images/";
    }
}
