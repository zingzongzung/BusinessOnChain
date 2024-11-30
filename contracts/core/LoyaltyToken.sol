// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {DynamicToken} from "./../implementations/DynamicToken.sol";
import {ServiceToken} from "./../implementations/ServiceToken.sol";

contract LoyaltyToken is DynamicToken, ServiceToken {
    constructor(
        address defaultAdmin
    ) DynamicToken(defaultAdmin, "LoyaltyToken", "Token") {
        bytes32[] memory attributes = new bytes32[](2);
        attributes[0] = bytes32(abi.encodePacked("Name"));
        attributes[1] = bytes32(abi.encodePacked("Points"));
        _setTokenAttributes(attributes);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return
            "https://zzo.outsystemscloud.com/IPFSOutsystems/rest/LoyaltyTokenURI/";
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(DynamicToken, ServiceToken) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
