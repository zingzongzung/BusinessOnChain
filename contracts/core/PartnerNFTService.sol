// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {LoyaltyTokenAttributes} from "./../libraries/LoyaltyTokenAttributes.sol";
import {IDynamicToken} from "./../interfaces/IDynamicToken.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract PartnerNFTService is IERC721Receiver {
    // Mapping to track token owners
    mapping(address => mapping(uint256 => address)) public tokenOwners;

    event TokenReceived(
        address indexed from,
        uint256 tokenId,
        address indexed tokenContract
    );
    event TokensReceived(
        address indexed from,
        address indexed tokenContract,
        uint256[] tokenIds
    );

    function transferPartnerNFT(uint businessTokenId) external {}

    // Bulk function to transfer multiple NFTs
    function bulkReceive(
        address tokenContract,
        uint256[] calldata tokenIds,
        address businessTokenAddress,
        uint businessTokenId
    ) external {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];

            // Transfer the token from the sender to this contract
            IERC721(tokenContract).safeTransferFrom(
                msg.sender,
                address(this),
                tokenId
            );

            // Record the token's owner
            tokenOwners[tokenContract][tokenId] = msg.sender;

            emit TokenReceived(msg.sender, tokenId, tokenContract);
        }

        emit TokensReceived(msg.sender, tokenContract, tokenIds);
    }

    // Allow token withdrawal by the owner
    function withdrawToken(address tokenContract, uint256 tokenId) external {
        require(
            tokenOwners[tokenContract][tokenId] == msg.sender,
            "Not the token owner"
        );

        // Clear the ownership record
        tokenOwners[tokenContract][tokenId] = address(0);

        // Transfer the token back to the owner
        IERC721(tokenContract).safeTransferFrom(
            address(this),
            msg.sender,
            tokenId
        );
    }

    // Withdraw multiple tokens
    function bulkWithdraw(
        address tokenContract,
        uint256[] calldata tokenIds
    ) external {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(
                tokenOwners[tokenContract][tokenId] == msg.sender,
                "Not the token owner"
            );

            // Clear the ownership record
            tokenOwners[tokenContract][tokenId] = address(0);

            // Transfer the token back to the owner
            IERC721(tokenContract).safeTransferFrom(
                address(this),
                msg.sender,
                tokenId
            );
        }
    }

    // Implement IERC721Receiver to accept ERC-721 tokens
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
