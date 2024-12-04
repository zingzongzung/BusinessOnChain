// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {NodeToken} from "./../implementations/NodeToken.sol";
import {LoyaltyTokenAttributes} from "./../libraries/LoyaltyTokenAttributes.sol";

contract ServiceTokenV2 is NodeToken {
    error NotEnoughPoints();

    constructor(
        address defaultAdmin
    ) NodeToken(defaultAdmin, "LoyaltyToken", "LTK", false) {
        bytes32[] memory attributes = new bytes32[](2);
        attributes[0] = LoyaltyTokenAttributes.NAME_ATTR;
        attributes[1] = LoyaltyTokenAttributes.POINTS_ATTR;
        _setTokenAttributes(attributes);asdf
    }

    function addPoints(
        uint tokenId,
        uint rootTokenId,
        address rootFatherAddress
    ) external {
        uint currentPoints = uint(
            getTraitValue(tokenId, LoyaltyTokenAttributes.POINTS_ATTR)
        );

        NodeToken ss = NodeToken(rootFatherAddress);

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
