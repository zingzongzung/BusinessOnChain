// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {NodeToken} from "./../implementations/NodeToken.sol";
import {Constants} from "./../libraries/Constants.sol";

abstract contract ChildToken is NodeToken {
    constructor(
        address defaultAdmin,
        string memory name,
        string memory symbol
    ) NodeToken(defaultAdmin, name, symbol, false) {
        _addBaseTokenAddtribute(Constants.FATHER_TOKEN_ID);
        _addBaseTokenAddtribute(Constants.FATHER_TOKEN_ADDRESS);
    }

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
        _setTrait(tokenId, Constants.FATHER_TOKEN_ID, bytes32(nodeFatherId));
        _setTrait(
            tokenId,
            Constants.FATHER_TOKEN_ADDRESS,
            bytes32(uint256(uint160(nodeFatherAddress)))
        );
    }

    function getFatherToken(uint tokenId) public view returns (uint, address) {
        Token memory token = fatherNode[tokenId];
        return (token.tokenId, token.addressId);
    }
}
