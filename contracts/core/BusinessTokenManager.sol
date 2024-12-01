// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ProviderTokenManager} from "./../implementations/ProviderTokenManager.sol";

contract BusinessTokenManager is ProviderTokenManager {
    constructor(
        address businessTokenAddress
    ) ProviderTokenManager(businessTokenAddress) {}
}
