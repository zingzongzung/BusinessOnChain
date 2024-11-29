// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {DynamicToken} from "./../implementations/DynamicToken.sol";

contract BusinessToken is DynamicToken {
    constructor(
        address defaultAdmin,
        address minter
    ) DynamicToken(defaultAdmin, minter, "BusinessToken", "BTK") {}

    function _baseURI() internal view virtual override returns (string memory) {
        return
            "https://zzo.outsystemscloud.com/IPFSOutsystems/rest/BusinessTokenURI/";
    }
}
