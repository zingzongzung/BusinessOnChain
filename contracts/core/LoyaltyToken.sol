// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ServiceToken} from "./../implementations/ServiceToken.sol";
import {LoyaltyTokenAttributes} from "./../libraries/LoyaltyTokenAttributes.sol";

contract LoyaltyToken is ServiceToken {
    constructor(
        address defaultAdmin
    ) ServiceToken(defaultAdmin, "LoyaltyToken", "Token") {
        bytes32[] memory attributes = new bytes32[](2);
        attributes[0] = LoyaltyTokenAttributes.NAME_ATTR;
        attributes[1] = LoyaltyTokenAttributes.POINTS_ATTR;
        _setTokenAttributes(attributes);
    }

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

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ServiceToken) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
