// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

contract LandInspector {
    struct LandInspectorDetails {
        address id;
        uint256 jobId;
        string name;
        string designation;
        int256 age;
    }

    function addLandInspector(
        address _id,
        uint256 _jobId,
        string memory _name,
        string memory _designation,
        int256 _age
    ) internal pure returns (LandInspectorDetails memory) {
        return LandInspectorDetails(_id, _jobId, _name, _designation, _age);
    }
}
