// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IGasback} from "./../interfaces/IGasback.sol";

contract GasbackService is Ownable {
    IGasback public gasback;

    constructor(address _gasback) Ownable(msg.sender) {
        gasback = IGasback(_gasback);
    }

    function updateGasback(address _gasback) external {
        gasback = IGasback(_gasback);
    }

    function registerForGasback(
        address gasbackContractAddress
    ) public onlyOwner {
        gasback.register(owner(), gasbackContractAddress);
    }
}
