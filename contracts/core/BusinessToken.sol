// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {DynamicToken} from "./../implementations/DynamicToken.sol";
import {ProviderToken} from "./../implementations/ProviderToken.sol";

contract BusinessToken is DynamicToken, ProviderToken {
    constructor(
        address defaultAdmin
    ) DynamicToken(defaultAdmin, "BusinessToken", "BTK") {
        bytes32[] memory attributes = new bytes32[](2);
        attributes[0] = bytes32(abi.encodePacked("Name"));
        attributes[1] = bytes32(abi.encodePacked("Sector"));
        _setTokenAttributes(attributes);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return
            "https://personal-ixqe4210.outsystemscloud.com/NFTApi/rest/BusinessTokenURI/";
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(DynamicToken, ProviderToken) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
