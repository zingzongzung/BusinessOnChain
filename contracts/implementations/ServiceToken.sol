// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IServiceToken} from "./../interfaces/IServiceToken.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

abstract contract ServiceToken is IServiceToken, ERC165 {
    using ERC165Checker for address;

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IServiceToken).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
