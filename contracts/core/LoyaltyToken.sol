// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {DynamicToken} from "./../implementations/DynamicToken.sol";
import {ServiceToken} from "./../implementations/ServiceToken.sol";

contract LoyaltyToken is DynamicToken, ServiceToken {
    constructor(
        address defaultAdmin,
        address minter
    )
        DynamicToken(
            defaultAdmin,
            minter,
            "LoyaltyToken",
            "Token",
            "contracts.storage.erc7496-loyaltytoken"
        )
    {}

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
