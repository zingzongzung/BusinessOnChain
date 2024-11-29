// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {DynamicToken} from "./../implementations/DynamicToken.sol";
import {EntityToken} from "./../implementations/EntityToken.sol";

contract BusinessToken is DynamicToken, EntityToken {
    constructor(
        address defaultAdmin,
        address minter
    )
        DynamicToken(
            defaultAdmin,
            minter,
            "BusinessToken",
            "BTK",
            "contracts.storage.erc7496-businesstoken"
        )
    {}

    function _baseURI() internal view virtual override returns (string memory) {
        return
            "https://zzo.outsystemscloud.com/IPFSOutsystems/rest/BusinessTokenURI/";
    }
}
