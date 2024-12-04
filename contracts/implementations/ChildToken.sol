// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {NodeToken} from "./../implementations/NodeToken.sol";

abstract contract ChildToken is NodeToken {
    constructor(
        address defaultAdmin,
        string memory name,
        string memory symbol
    ) NodeToken(defaultAdmin, name, symbol, false) {}
}
