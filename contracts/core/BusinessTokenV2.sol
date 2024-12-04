// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {NodeToken} from "./../implementations/NodeToken.sol";

contract BusinessTokenV2 is NodeToken {
    constructor(
        address defaultAdmin
    ) NodeToken(defaultAdmin, "BusinessToken", "BTK", true) {
        bytes32[] memory attributes = new bytes32[](2);
        attributes[0] = bytes32(abi.encodePacked("Name"));
        attributes[1] = bytes32(abi.encodePacked("Sector"));
        _setTokenAttributes(attributes);
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

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(NodeToken) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
