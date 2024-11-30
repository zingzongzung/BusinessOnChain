// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ServiceTokenManager} from "./../implementations/ServiceTokenManager.sol";

contract LoyaltyTokenManager is ServiceTokenManager {
    constructor(address loyaltyToken) ServiceTokenManager(loyaltyToken) {}

    function addPoints(
        uint tokenId,
        uint rootTokenId,
        address rootFatherAddress
    )
        external
        verifyRelationPermission(tokenId, rootTokenId, rootFatherAddress)
    {}
}
