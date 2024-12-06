// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {NodeToken} from "./../implementations/NodeToken.sol";

abstract contract ChildToken is NodeToken {
    constructor(
        address defaultAdmin,
        string memory name,
        string memory symbol
    ) NodeToken(defaultAdmin, name, symbol, false) {}

    function safeMint(
        address to,
        bytes32 _imageId,
        bytes32[] memory attributes,
        uint nodeFatherId,
        address nodeFatherAddress
    )
        external
        virtual
        onlyRegisteredFatherNode(nodeFatherId, nodeFatherAddress)
    {
        uint tokenId = internalSafeMint(to, _imageId, attributes);
        fatherNode[tokenId] = Token(nodeFatherId, nodeFatherAddress);
    }
}
