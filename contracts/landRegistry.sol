// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

// All Imports
import "./Registry.sol";
import "./Buyer.sol";
import "./Payment.sol";
import "./Seller.sol";
import "./LandInspector.sol";
import "./LandRequest.sol";
import "./stringUtils.sol";

// Main Contract Starts

contract Land is Registry, Buyer, Seller, LandInspector, LandRequest, Payment {
    // Designations Whose consensus are required to complete the Land Registry process
    uint256[] FileInspectors_JobID = [2341, 4567, 7889, 9892, 8990];
    string[] Designations = [
        "Deputy Commissioner",
        "Tehsildar",
        "Civil Engineer",
        "Registar",
        "Accountant"
    ];

    // mappings
    mapping(bytes32 => mapping(uint256 => LandDetails)) private _LandRegistered;
    mapping(bytes32 => mapping(uint256 => mapping(address => LandDetails)))
        public _requestLandRegistration;
    mapping(bytes32 => mapping(uint256 => mapping(address => bool[5])))
        public _LandConsensus;
    mapping(address => LandInspectorDetails) private _LandInspectors;
    mapping(address => BuyerDetails) private _Buyer;
    mapping(address => SellerDetails) private _Seller;
    mapping(bytes32 => mapping(uint256 => mapping(address => LandRequestDetails))) _LandRequests;
    mapping(bytes32 => mapping(address => PaymentLog)) private _PaymentsLog;

    // Check Existence
    mapping(address => bool) private _Inspectors;
    mapping(address => bool) private registeredSeller;
    mapping(address => bool) private registeredBuyer;
    mapping(address => bool) private sellerVerified;
    mapping(address => bool) private buyerVerified;
    mapping(bytes32 => mapping(uint256 => bool)) private LandVerified;
    mapping(uint256 => bool) private _checkTransaction;

    // state variables
    address CurrentOfficer;

    // All Events Declarations
    event Registration(address _registrationId, string message);
    event Landrequested(address _sellerId, string message);
    event registryRequest(address _sellerId, string message);
    event requestApproved(address _buyerId);
    event Verified(address _id, string message);
    event Rejected(address _id, string message);
    event caseClosed(bytes32 _id, uint256 Property, string message);
    event messageEmit(string message);
    event messageEmit(uint256 message);
    event property(LandDetails land);

    // All Modifiers
    modifier isInspector() {
        require(_Inspectors[msg.sender], "Is Not Inspector");
        _;
    }

    modifier isBuyer() {
        require(registeredBuyer[msg.sender]);
        _;
    }

    modifier isSeller() {
        require(registeredSeller[msg.sender]);
        _;
    }

    modifier isOwner(bytes32 localHash, uint256 propertyPID) {
        require(
            _LandRegistered[localHash][propertyPID].currentOwner == msg.sender
        );
        _;
    }

    // Functions and Constructor
    constructor() {
        CurrentOfficer = msg.sender;
        _LandInspectors[CurrentOfficer] = LandInspector.addLandInspector(
            CurrentOfficer,
            2341,
            "Pearl Kothari",
            "Deputy Commissioner",
            21
        );
        _Inspectors[CurrentOfficer] = true;
    }

    // Officer Work
    function AddLandOfficers(
        address _id,
        uint256 _jobId,
        string memory _name,
        string memory _designation,
        int256 _age
    ) public {
        require(_Inspectors[msg.sender]);
        _LandInspectors[_id] = LandInspector.addLandInspector(
            _id,
            _jobId,
            _name,
            _designation,
            _age
        );
        _Inspectors[_id] = true;
    }

    function getOfficers(address _id)
        public
        view
        isInspector
        returns (LandInspectorDetails memory)
    {
        return _LandInspectors[_id];
    }

    function ApproveBuyer(address _id) public isInspector {
        require(registeredBuyer[_id], "Buyer Not Registered");
        buyerVerified[_id] = true;
        // emit Verified(_id,"Buyer Approved");
    }

    function RejectBuyer(address _id) public isInspector {
        require(registeredBuyer[_id], "Buyer Not Registered");
        buyerVerified[_id] = false;
        // emit Rejected(_id,"Buyer Rejected");
    }

    function fetchBuyerDetails(address _id)
        public
        view
        returns (BuyerDetails memory)
    {
        return _Buyer[_id];
    }

    function ApproveSeller(address _id) public isInspector {
        require(registeredSeller[_id], "Seller not Registered");
        sellerVerified[_id] = true;
        // emit Verified(_id,"Seller Approved");
    }

    function rejectSeller(address _id) public isInspector {
        require(registeredSeller[_id], "Seller not Registered");
        sellerVerified[_id] = false;
        // emit Rejected(_id,"Seller Rejected");
    }

    function fetchSellerDetails(address _id)
        public
        view
        returns (SellerDetails memory)
    {
        return _Seller[_id];
    }

    function ApproveLand(
        address _id,
        string memory _city,
        string memory _state,
        string memory _district,
        uint256 _propertyPID
    ) public isInspector {
        bytes32 localHash = sha256(abi.encodePacked(_city, _state, _district));
        require(
            StringUtils.equal(
                _requestLandRegistration[localHash][_propertyPID][_id].status,
                "Pending"
            )
        );
        bool eligible = false;
        uint256 index;
        uint256 sz = FileInspectors_JobID.length;
        uint256 jobId = _LandInspectors[msg.sender].jobId;
        for (uint256 i = 0; i < sz; i++) {
            if (FileInspectors_JobID[i] == jobId) {
                eligible = true;
                index = i;
                break;
            }
        }

        require(eligible == true, "You are not assigned to this client");

        require(LandVerified[localHash][_propertyPID] == false, "Case Closed");

        _LandConsensus[localHash][_propertyPID][_id][index] = true;

        bool approved = false;
        for (uint256 i = 0; i < sz; i++) {
            if (_LandConsensus[localHash][_propertyPID][_id][i] == false) {
                approved = false;
                break;
            }
            approved = true;
        }

        if (approved == true) {
            _requestLandRegistration[localHash][_propertyPID][_id]
                .status = "Case-Closed";
            _LandRegistered[localHash][_propertyPID] = _requestLandRegistration[
                localHash
            ][_propertyPID][_id];
            LandVerified[localHash][_propertyPID] = true;
            // emit caseClosed(localHash,_propertyPID,"Land Registered Succesfully");
        }
    }

    function RejectLandRegistry(
        address _id,
        string memory _city,
        string memory _state,
        string memory _district,
        uint256 _propertyPID
    ) public isInspector {
        bool eligible = false;
        uint256 index;
        uint256 sz = FileInspectors_JobID.length;
        uint256 jobId = _LandInspectors[msg.sender].jobId;
        for (uint256 i = 0; i < sz; i++) {
            if (FileInspectors_JobID[i] == jobId) {
                eligible = true;
                index = i;
                break;
            }
        }

        require(eligible == true, "You are not assigned to this client");

        bytes32 localHash = sha256(abi.encodePacked(_city, _state, _district));
        require(LandVerified[localHash][_propertyPID] == false, "Case Closed");

        _requestLandRegistration[localHash][_propertyPID][_id]
            .status = "Rejected";
    }

    function fetchLandDetails(
        uint256 _propertyPID,
        string memory _city,
        string memory _state,
        string memory _district
    ) public {
        bytes32 localHash = sha256(abi.encodePacked(_city, _state, _district));
        require(
            LandVerified[localHash][_propertyPID] == true,
            "Property Not Approved Till Now"
        );
        emit property(_LandRegistered[localHash][_propertyPID]);
    }

    // Buyer Work
    function AddBuyer(
        address _id,
        string memory name,
        uint256 age,
        string memory city,
        string memory state,
        string memory aadharNumber,
        string memory panNumber
    ) public {
        require(registeredBuyer[_id] == false);
        _Buyer[_id] = Buyer.AddBuyerDetails(
            _id,
            name,
            age,
            city,
            state,
            aadharNumber,
            panNumber
        );
        registeredBuyer[_id] = true;
        emit Registration(
            _id,
            "Request Generated Wait For Officer to Approve to do further transactions"
        );
    }

    function RequestLand(
        uint256 _propertyPID,
        string memory _city,
        string memory _state,
        string memory _district,
        uint256 _bid
    ) public isBuyer {
        bytes32 localHash = sha256(abi.encodePacked(_city, _state, _district));
        require(
            LandVerified[localHash][_propertyPID] == true,
            "Property Not Approved Till Now"
        );
        require(
            _LandRequests[localHash][_propertyPID][msg.sender].sellerId ==
                address(0),
            "Request Pending"
        );

        _LandRequests[localHash][_propertyPID][msg.sender] = LandRequest
            .addLandRequest(
                _LandRegistered[localHash][_propertyPID].currentOwner,
                msg.sender,
                localHash,
                _propertyPID,
                _bid,
                false
            );
    }

    // Payment

    function _transferOwnerShip(
        bytes32 localHash,
        uint256 propertyPID,
        address _newOwner
    ) private isOwner(localHash, propertyPID) returns (string memory) {
        _LandRegistered[localHash][propertyPID].currentOwner = _newOwner;
        return "Owner Updated";
    }

    function LandPayment(
        address payable receiverId,
        uint256 _propertyPID,
        string memory _city,
        string memory _state,
        string memory _district
    ) public payable isBuyer {
        bytes32 localHash = sha256(abi.encodePacked(_city, _state, _district));
        require(
            _LandRequests[localHash][_propertyPID][msg.sender].AcceptOffer ==
                true
        );
        emit messageEmit(
            msg.value - _LandRegistered[localHash][_propertyPID].landPrice
        );
        require(
            msg.value == _LandRegistered[localHash][_propertyPID].landPrice
        );

        (bool success, ) = receiverId.call{value: msg.value}("");
        if (success == true) {
            _transferOwnerShip(localHash, _propertyPID, msg.sender);
            _PaymentsLog[localHash][receiverId] = Payment.registerPayment(
                receiverId,
                msg.sender,
                localHash,
                _propertyPID,
                msg.value,
                block.timestamp
            );
        } else {
            emit messageEmit("Transaction Failed");
        }
    }

    // Seller Work
    function getLandStatus(
        address _id,
        string memory _city,
        string memory _state,
        string memory _district,
        uint256 _propertyPID
    ) public view isSeller returns (string memory) {
        bytes32 localHash = sha256(abi.encodePacked(_city, _state, _district));
        return _requestLandRegistration[localHash][_propertyPID][_id].status;
    }

    function AddSeller(
        address _id,
        string memory name,
        uint256 age,
        string memory city,
        string memory state,
        string memory aadharNumber,
        string memory panNumber
    ) public {
        require(registeredSeller[_id] == false);
        _Seller[_id] = Seller.AddSellerDetails(
            _id,
            name,
            age,
            city,
            state,
            aadharNumber,
            panNumber
        );
        registeredSeller[_id] = true;
        emit Registration(
            _id,
            "Request Generated Wait For Officer to Approve to do further transactions"
        );
    }

    function AddLand(
        uint256 _propertyPID,
        uint256 _area,
        string memory _city,
        string memory _state,
        string memory _district,
        uint256 _landPrice
    ) public isSeller {
        // Local Hash is the hash of combination city ,State and district
        // To identify Specific City in Specific State and district
        bytes32 localHash = sha256(abi.encodePacked(_city, _state, _district));
        string memory status = _requestLandRegistration[localHash][
            _propertyPID
        ][msg.sender].status;
        require(
            LandVerified[localHash][_propertyPID] == false,
            "This Property is already registered"
        );
        require(
            StringUtils.equal(status, "Rejected") ||
                StringUtils.equal(status, "") ||
                StringUtils.equal(status, "Case-Closed"),
            "Already Request is pending for this Land"
        );

        _requestLandRegistration[localHash][_propertyPID][msg.sender] = Registry
            .RegisterLand(
                _area,
                _city,
                _state,
                _district,
                _landPrice * 1000000000000000000,
                _propertyPID,
                localHash,
                msg.sender,
                "Pending"
            );

        emit registryRequest(msg.sender, "Request Generated Succesfully");
    }

    function ApproveBuyRequest(
        uint256 _propertyPID,
        string memory _city,
        string memory _state,
        string memory _district,
        address buyerId
    ) public isSeller {
        // Local Hash is the hash of combination city ,State and district
        // To identify Specific City in Specific State and district
        bytes32 localHash = sha256(abi.encodePacked(_city, _state, _district));
        _LandRequests[localHash][_propertyPID][buyerId].AcceptOffer = true;
    }
}
