// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IDynamicToken} from "./../interfaces/IDynamicToken.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {GelatoVRFConsumerBase} from "./../gelato_vrf/GelatoVRFConsumerBase.sol";

contract PartnerNFTService is IERC721Receiver, GelatoVRFConsumerBase {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    //errors
    error NotAllowedToTransferPartnerNFT(uint, address, address);

    //Data that holds information about partner nfts holded on this contract
    mapping(address => mapping(uint => EnumerableSet.AddressSet)) businessTokenPartnerNFTS;
    mapping(address => mapping(address => mapping(uint => EnumerableSet.UintSet))) partnerNfts;

    //VRF
    address private vrfOperatorAddress;
    struct VRFPartnerNFTRequest {
        address partnerNftAddress;
        address businessTokenAddress;
        uint businessTokenId;
        address receiverNFTAddress;
    }

    //Token Received Events
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

    constructor(address vrfOperator) {
        vrfOperatorAddress = vrfOperator;
    }

    function transferPartnerNFT(
        uint businessTokenId,
        address businessTokenAddress,
        address partnerNftAddress,
        address receiverNFTAddress,
        bool useVRF
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
        if (useVRF) {
            VRFPartnerNFTRequest memory requestData = VRFPartnerNFTRequest(
                partnerNftAddress,
                businessTokenAddress,
                businessTokenId,
                receiverNFTAddress
            );
            requestRandomness(requestData);
        } else {
            IERC721 partnerNFTContract = IERC721(partnerNftAddress);
            partnerNFTContract.safeTransferFrom(
                address(this),
                receiverNFTAddress,
                getPartnerNFTTokenId(
                    partnerNftAddress,
                    businessTokenAddress,
                    businessTokenId,
                    0 //in this case the element retrieved will always be the first one
                )
            );
        }
    }

    function _transferPartnerNFT(
        VRFPartnerNFTRequest memory partnerNFT,
        uint randomness
    ) internal {
        IERC721 partnerNFTContract = IERC721(partnerNFT.partnerNftAddress);
        partnerNFTContract.safeTransferFrom(
            address(this),
            partnerNFT.receiverNFTAddress,
            getPartnerNFTTokenId(
                partnerNFT.partnerNftAddress,
                partnerNFT.businessTokenAddress,
                partnerNFT.businessTokenId,
                randomness
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
            ].add(tokenId);

            emit TokenReceived(msg.sender, tokenId, partnerNftAddress);
        }

        emit TokensReceived(msg.sender, partnerNftAddress, tokenIds);
    }

    //Helper functions to list partnerNFTs
    function getPartnerNftAddresses(
        address businessTokenAddress,
        uint businessTokenId
    ) external view returns (address[] memory) {
        uint256 setLength = businessTokenPartnerNFTS[businessTokenAddress][
            businessTokenId
        ].length();
        address[] memory addressArray = new address[](setLength);

        for (uint256 i = 0; i < setLength; i++) {
            addressArray[i] = businessTokenPartnerNFTS[businessTokenAddress][
                businessTokenId
            ].at(i);
        }

        return addressArray;
    }

    function getPartnerNFTTokenIds(
        address partnerNftAddress,
        address businessTokenAddress,
        uint businessTokenId
    ) external view returns (uint[] memory) {
        uint256 setLength = partnerNfts[partnerNftAddress][
            businessTokenAddress
        ][businessTokenId].length();
        uint[] memory tokenIds = new uint[](setLength);

        for (uint256 i = 0; i < setLength; i++) {
            tokenIds[i] = partnerNfts[partnerNftAddress][businessTokenAddress][
                businessTokenId
            ].at(i);
        }

        return tokenIds;
    }

    //Gelato VRF
    function requestRandomness(
        VRFPartnerNFTRequest memory requestData
    ) internal {
        _requestRandomness(abi.encode(requestData));
    }

    function _fulfillRandomness(
        uint256 randomness,
        uint256,
        bytes memory extraData
    ) internal override {
        VRFPartnerNFTRequest memory partnerNFT = abi.decode(
            extraData,
            (VRFPartnerNFTRequest)
        );
        _transferPartnerNFT(partnerNFT, randomness);
    }

    function _operator() internal view virtual override returns (address) {
        return vrfOperatorAddress;
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
        uint businessTokenId,
        uint randomness
    ) internal returns (uint tokenId) {
        uint maxIndex = partnerNfts[partnerNftAddress][businessTokenAddress][
            businessTokenId
        ].length();
        uint randomIndex = randomness % maxIndex;
        tokenId = partnerNfts[partnerNftAddress][businessTokenAddress][
            businessTokenId
        ].at(randomIndex);
        partnerNfts[partnerNftAddress][businessTokenAddress][businessTokenId]
            .remove(tokenId);
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
