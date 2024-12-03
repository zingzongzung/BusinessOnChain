// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IProviderToken} from "./../interfaces/IProviderToken.sol";
import {IDynamicToken} from "./../interfaces/IDynamicToken.sol";

abstract contract ProviderTokenManager {
    address providerTokenAddress;

    constructor(address _providerTokenAddress) {
        providerTokenAddress = _providerTokenAddress;
    }

    function safeMint(
        address to,
        bytes32 imageId,
        bytes32[] memory attributes
    ) external {
        IDynamicToken providerToken = IDynamicToken(providerTokenAddress);
        providerToken.safeMint(to, imageId, attributes);
    }
}
