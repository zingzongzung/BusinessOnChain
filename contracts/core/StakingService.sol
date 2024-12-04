// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {LoyaltyTokenAttributes} from "./../libraries/LoyaltyTokenAttributes.sol";
import {IDynamicToken} from "./../interfaces/IDynamicToken.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract StakingService is IERC721Receiver {
    mapping(address => mapping(uint => address)) stakedAssets;
    mapping(address => mapping(address => uint)) stakedCount;

    error NotAuthorizedToUnstake();

    function unStakeNFT(address nftAddress, uint tokenId) external {
        address originalOwner = stakedAssets[nftAddress][tokenId];
        if (msg.sender != originalOwner) {
            revert NotAuthorizedToUnstake();
        }
        IERC721 nftContract = IERC721(nftAddress);
        nftContract.safeTransferFrom(address(this), msg.sender, tokenId);
        stakedAssets[nftAddress][tokenId] = address(0);
        stakedCount[nftAddress][msg.sender] -= 1;
    }

    /**
     *
     * Must approve transacting on behalf of user first
     *
     */
    function stakeNFT(address nftAddress, uint tokenId) external {
        IERC721 nftContract = IERC721(nftAddress);
        nftContract.safeTransferFrom(msg.sender, address(this), tokenId);
        stakedAssets[nftAddress][tokenId] = msg.sender;
        stakedCount[nftAddress][msg.sender] += 1;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
