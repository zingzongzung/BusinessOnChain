// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {DynamicToken} from "./../implementations/DynamicToken.sol";

contract LoyaltyToken is DynamicToken {
    constructor(
        address defaultAdmin,
        address minter,
        string memory name,
        string memory symbol
    ) DynamicToken(defaultAdmin, minter, "LoyaltyToken", "Token") {}

    function _baseURI() internal view virtual override returns (string memory) {
        return
            "https://zzo.outsystemscloud.com/IPFSOutsystems/rest/LoyaltyTokenURI/";
    }
}
