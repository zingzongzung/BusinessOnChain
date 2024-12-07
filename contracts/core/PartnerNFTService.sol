// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {LoyaltyTokenAttributes} from "./../libraries/LoyaltyTokenAttributes.sol";
import {IDynamicToken} from "./../interfaces/IDynamicToken.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract PartnerNFTService is IERC721Receiver {
    using EnumerableSet for EnumerableSet.AddressSet;

    //errors
    error NotAllowedToTransferPartnerNFT(uint, address, address);

    //Data that holds information about partner nfts holded on this contract
    mapping(address => mapping(uint => EnumerableSet.AddressSet)) businessTokenPartnerNFTS;
    mapping(address => mapping(address => mapping(uint => uint[]))) partnerNfts;

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

    function transferPartnerNFT(
        uint businessTokenId,
        address businessTokenAddress,
        address partnerNftAddress,
        address receiverNFTAddress
    ) external {
        IERC721 businessToken = IERC721(businessTokenAddress);
        if (
            businessToken.ownerOf(businessTokenId) != msg.sender ||
            !isPartnerNft(
                businessTokenId,
                businessTokenAddress,
                partnerNftAddress
            )
        ) {
            revert NotAllowedToTransferPartnerNFT(
                businessTokenId,
                businessTokenAddress,
                partnerNftAddress
            );
        }
        IERC721 partnerNFTContract = IERC721(partnerNftAddress);
        partnerNFTContract.safeTransferFrom(
            address(this),
            receiverNFTAddress,
            getPartnerNFTTokenId(
                partnerNftAddress,
                businessTokenAddress,
                businessTokenId
            )
        );
    }

    // Bulk function to transfer multiple NFTs
    function bulkReceive(
        address partnerNftAddress,
        uint256[] calldata tokenIds,
        uint businessTokenId,
        address businessTokenAddress
    ) external {
        IERC721 businessToken = IERC721(businessTokenAddress);
        businessToken.ownerOf(businessTokenId); //This will revert if the token hasnt been minted or has been burned. In that case we shouldnt allow the items to be sent to this contract.

        addPartnerNFT(businessTokenId, businessTokenAddress, partnerNftAddress);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];

            // Transfer the token from the sender to this contract
            IERC721(partnerNftAddress).safeTransferFrom(
                msg.sender,
                address(this),
                tokenId
            );

            // Record the token's owner
            partnerNfts[partnerNftAddress][businessTokenAddress][
                businessTokenId
            ].push(tokenId);

            emit TokenReceived(msg.sender, tokenId, partnerNftAddress);
        }

        emit TokensReceived(msg.sender, partnerNftAddress, tokenIds);
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

    function addPartnerNFT(
        uint businessTokenId,
        address businessTokenAddress,
        address partnerNftAddress
    ) internal {
        if (
            !isPartnerNft(
                businessTokenId,
                businessTokenAddress,
                partnerNftAddress
            )
        ) {
            businessTokenPartnerNFTS[businessTokenAddress][businessTokenId].add(
                    partnerNftAddress
                );
        }
    }

    function getPartnerNFTTokenId(
        address partnerNftAddress,
        address businessTokenAddress,
        uint businessTokenId
    ) internal returns (uint tokenId) {
        tokenId = partnerNfts[partnerNftAddress][businessTokenAddress][
            businessTokenId
        ][
            partnerNfts[partnerNftAddress][businessTokenAddress][
                businessTokenId
            ].length - 1
        ];
        partnerNfts[partnerNftAddress][businessTokenAddress][businessTokenId]
            .pop();
    }

    function isPartnerNft(
        uint businessTokenId,
        address businessTokenAddress,
        address partnerNftAddress
    ) internal view returns (bool isPartner) {
        isPartner = businessTokenPartnerNFTS[businessTokenAddress][
            businessTokenId
        ].contains(partnerNftAddress);
    }
}
