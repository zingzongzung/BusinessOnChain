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

    function safeMint(address to, bytes32[] memory attributes) public {
        _safeMint(to, attributes);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(DynamicToken, EntityToken) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
