// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IServiceToken} from "./../interfaces/IServiceToken.sol";
import {DynamicToken} from "./../abstract/DynamicToken.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

abstract contract ServiceToken is IServiceToken, ERC165, DynamicToken {
    using ERC165Checker for address;

    constructor(
        address defaultAdmin,
        string memory name,
        string memory symbol
    ) DynamicToken(defaultAdmin, name, symbol) {}

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC165, IERC165, DynamicToken)
        returns (bool)
    {
        return
            interfaceId == type(IServiceToken).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
