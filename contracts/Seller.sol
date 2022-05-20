// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

contract Seller {
    struct SellerDetails {
        address id;
        string name;
        uint256 age;
        string city;
        string state;
        string aadharNumber;
        string panNumber;
    }

    function AddSellerDetails(
        address _id,
        string memory _name,
        uint256 _age,
        string memory _city,
        string memory _state,
        string memory _adharNumber,
        string memory _panNumber
    ) internal pure returns (SellerDetails memory) {
        return
            SellerDetails(
                _id,
                _name,
                _age,
                _city,
                _state,
                _adharNumber,
                _panNumber
            );
    }
}
