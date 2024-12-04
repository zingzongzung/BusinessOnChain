// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ChildToken} from "./../implementations/ChildToken.sol";
import {LoyaltyTokenAttributes} from "./../libraries/LoyaltyTokenAttributes.sol";

contract LoyaltyToken is ChildToken {
    error NotEnoughPoints();

    constructor(
        address defaultAdmin
    ) ChildToken(defaultAdmin, "LoyaltyToken", "LTK") {
        bytes32[] memory attributes = new bytes32[](2);
        attributes[0] = LoyaltyTokenAttributes.NAME_ATTR;
        attributes[1] = LoyaltyTokenAttributes.POINTS_ATTR;
        _setTokenAttributes(attributes);
    }

    function addPoints(
        uint tokenId,
        uint rootTokenId,
        address rootFatherAddress
    ) external {
        uint currentPoints = uint(
            getTraitValue(tokenId, LoyaltyTokenAttributes.POINTS_ATTR)
        );

        ChildToken ss = ChildToken(rootFatherAddress);

        (bool success, ) = rootFatherAddress.call(
            abi.encodeWithSignature(
                "getPointsMultiplier(address,uint256)",
                ss,
                tokenId
            )
        );

        super.setFatherManagedTrait(
            tokenId,
            LoyaltyTokenAttributes.POINTS_ATTR,
            bytes32(currentPoints + 1),
            rootTokenId,
            rootFatherAddress
        );
    }

    function redeemPoints(uint tokenId, uint pointsToRedeem) external {
        uint currentPoints = uint(
            getTraitValue(tokenId, LoyaltyTokenAttributes.POINTS_ATTR)
        );
        if (pointsToRedeem > currentPoints) {
            revert NotEnoughPoints();
        }

        setOwnerManagedTrait(
            tokenId,
            LoyaltyTokenAttributes.POINTS_ATTR,
            bytes32(currentPoints - pointsToRedeem)
        );
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return
            "https://personal-ixqe4210.outsystemscloud.com/BusinessOnChain_API/rest/Token/GetBusinessTokenURI/";
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
