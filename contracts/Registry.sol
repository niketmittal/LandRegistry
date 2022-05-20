// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

contract Registry {
    struct LandDetails {
        uint256 propertyPID;
        uint256 area;
        string city;
        string state;
        string district;
        uint256 landPrice;
        bytes32 localHash;
        address currentOwner;
        string status;
    }

    function RegisterLand(
        uint256 _area,
        string memory _city,
        string memory _state,
        string memory _district,
        uint256 _landPrice,
        uint256 _propertyPID,
        bytes32 localHash,
        address _owner,
        string memory status
    ) internal pure returns (LandDetails memory) {
        return
            LandDetails(
                _propertyPID,
                _area,
                _city,
                _state,
                _district,
                _landPrice,
                localHash,
                _owner,
                status
            );
    }

    event property(
        uint256 propertyPID,
        uint256 area,
        string city,
        string state,
        string district,
        uint256 landPrice,
        bytes32 localHash,
        address currentOwner,
        string status
    );

    function fetchLandDetails(LandDetails memory Land1) public {
        emit property(
            Land1.propertyPID,
            Land1.area,
            Land1.city,
            Land1.state,
            Land1.district,
            Land1.landPrice,
            Land1.localHash,
            Land1.currentOwner,
            Land1.status
        );
    }
}
