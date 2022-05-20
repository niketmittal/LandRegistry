// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

contract LandRequest {
    struct LandRequestDetails {
        address sellerId;
        address buyerId;
        bytes32 LocalHash;
        uint256 landId;
        uint256 _bid;
        bool AcceptOffer;
    }

    function addLandRequest(
        address _sellerId,
        address _buyerId,
        bytes32 _LocalHash,
        uint256 _landId,
        uint256 _bid,
        bool _AcceptOffer
    ) internal pure returns (LandRequestDetails memory) {
        return
            LandRequestDetails(
                _sellerId,
                _buyerId,
                _LocalHash,
                _landId,
                _bid,
                _AcceptOffer
            );
    }
}
