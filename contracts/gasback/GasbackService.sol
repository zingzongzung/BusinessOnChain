// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IGasback} from "./../interfaces/IGasback.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract GasbackService is IERC721Receiver {
    IGasback public gasback;
    uint gasbackTokenId;

    constructor(address _gasback) {
        gasback = IGasback(_gasback);
    }

    function registerForGasback() public {
        address me = address(this);
        gasbackTokenId = gasback.register(me, me);
        //assignContract(gasbackTokenId, contractToRegister);
        sendToken();
    }

    function sendToken() internal {
        IERC721 gasbackToken = IERC721(address(gasback));
        gasbackToken.safeTransferFrom(
            address(this),
            msg.sender,
            gasbackTokenId
        );
    }

    function getGasbackServiceTokenId() external view returns (uint tokenId) {
        return gasbackTokenId;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
