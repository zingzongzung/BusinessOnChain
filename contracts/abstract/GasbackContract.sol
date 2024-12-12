// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract GasbackContract is Ownable {
    constructor() Ownable(msg.sender) {}
}
