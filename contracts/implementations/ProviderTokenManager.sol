// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IDynamicToken} from "./../interfaces/IDynamicToken.sol";

abstract contract ProviderTokenManager {
    address providerTokenAddress;

    constructor(address _providerTokenAddress) {
        providerTokenAddress = _providerTokenAddress;
    }

    function safeMint(address to, bytes32[] memory attributes) public {
        IDynamicToken dynamicToken = IDynamicToken(providerTokenAddress);
        dynamicToken.safeMint(to, attributes);
    }
}
