// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

contract Payment {
    struct PaymentLog {
        address receiverId;
        address payerId;
        bytes32 _localHash;
        uint256 _propertyPID;
        uint256 amount;
        uint256 timestamp;
    }

    function registerPayment(
        address _receiver,
        address _payer,
        bytes32 _localHash,
        uint256 _propertyPID,
        uint256 _amount,
        uint256 _timestamp
    ) internal pure returns (PaymentLog memory) {
        return
            PaymentLog(
                _receiver,
                _payer,
                _localHash,
                _propertyPID,
                _amount,
                _timestamp
            );
    }
}
