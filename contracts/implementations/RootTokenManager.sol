// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IRootToken} from "./../interfaces/IRootToken.sol";

abstract contract RootTokenManager {
    function tryInvokeMethodOnManagedServices(
        string memory method,
        bytes[] memory params
    ) external {}

    function invokeMethod(
        string memory method,
        bytes[] memory params,
        address serviceAddress
    ) internal {
        (bool success, ) = serviceAddress.call(
            abi.encodeWithSignature(method, decodeParams(params))
        );
    }

    function decodeParams(
        bytes[] memory params
    ) internal pure returns (bytes memory) {
        bytes memory encodedParams;

        for (uint256 i = 0; i < params.length; i++) {
            // Concatenate encoded parameters
            encodedParams = abi.encodePacked(encodedParams, params[i]);
        }

        return encodedParams;
    }
}
