// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IServiceToken} from "./../interfaces/IServiceToken.sol";
import {IEntityToken} from "./../interfaces/IEntityToken.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

abstract contract ServiceToken is IServiceToken, ERC165 {
    using ERC165Checker for address;

    error NotAnEntityTokenAddress();
    error ServiceNotAddedToThisEntity();

    bytes4 public constant ENTITY_INTERFACE_ID = type(IEntityToken).interfaceId;

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IServiceToken).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    //This should be specified so that every service contract uses this to mint
    modifier canMint(uint tokenFatherId, address tokenFatherAddress) {
        if (!tokenFatherAddress.supportsInterface(ENTITY_INTERFACE_ID)) {
            revert NotAnEntityTokenAddress();
        }

        IEntityToken entityToken = IEntityToken(tokenFatherAddress);
        if (!entityToken.hasService(tokenFatherId, address(this))) {
            revert ServiceNotAddedToThisEntity();
        }
        _;
    }
}
