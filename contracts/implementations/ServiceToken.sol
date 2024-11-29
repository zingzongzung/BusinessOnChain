// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IServiceToken} from "./../interfaces/IServiceToken.sol";

abstract contract ServiceToken is IServiceToken {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual returns (bool) {
        return interfaceId == type(IServiceToken).interfaceId;
    }
}
