// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

contract Land {
    struct Landreg {
        uint256 id;
        uint256 area;
        string city;
        string state;
        uint256 landPrice;
        uint256 propertyPID;
    }

    struct Buyer {
        address id;
        string name;
        uint256 age;
        string city;
        string aadharNumber;
        string panNumber;
    }

    struct Seller {
        address id;
        string name;
        uint256 age;
        string aadharNumber;
        string panNumber;
    }

    struct LandInspector {
        uint256 id;
        string name;
        uint256 age;
        string designation;
    }

    struct LandRequest {
        uint256 reqId;
        address sellerId;
        address buyerId;
        uint256 landId;
    }

    //Mappings
    mapping(uint256 => Landreg) public lands;
    mapping(uint256 => LandInspector) public InspectorMapping;
    mapping(address => Seller) public SellerMapping;
    mapping(address => Buyer) public BuyerMapping;
    mapping(uint256 => LandRequest) public RequestsMapping;

    mapping(address => bool) public RegisteredAddressMapping;
    mapping(address => bool) public RegisteredSellerMapping;
    mapping(address => bool) public RegisteredBuyerMapping;
    mapping(address => bool) public SellerVerification;
    mapping(address => bool) public SellerRejection;
    mapping(address => bool) public BuyerVerification;
    mapping(address => bool) public BuyerRejection;
    mapping(uint256 => bool) public LandVerification;
    mapping(uint256 => address) public LandOwner;
    mapping(uint256 => bool) public RequestStatus;
    mapping(uint256 => bool) public RequestedLands;
    mapping(uint256 => bool) public PaymentReceived;

    address public Land_Inspector;
    address[] public sellers;
    address[] public buyers;

    uint256 public landsCount;
    uint256 public inspectorsCount;
    uint256 public sellersCount;
    uint256 public buyersCount;
    uint256 public requestsCount;

    event Registration(address _registrationId);
    event AddingLand(uint256 indexed _landId);
    event Landrequested(address _sellerId);
    event requestApproved(address _buyerId);
    event Verified(address _id);
    event Rejected(address _id);

    constructor() {
        Land_Inspector = msg.sender;
        addLandInspector("Tehsildaar", 45, "Tehsil Manager");
    }

    function addLandInspector(
        string memory _name,
        uint256 _age,
        string memory _designation
    ) private {
        inspectorsCount++;
        InspectorMapping[inspectorsCount] = LandInspector(
            inspectorsCount,
            _name,
            _age,
            _designation
        );
    }

    modifier isLandInspector() {
        require(Land_Inspector == msg.sender);
        _;
    }

    function getLandsCount() public view returns (uint256) {
        return landsCount;
    }

    function getBuyersCount() public view returns (uint256) {
        return buyersCount;
    }

    function getSellersCount() public view returns (uint256) {
        return sellersCount;
    }

    function getRequestsCount() public view returns (uint256) {
        return requestsCount;
    }

    function getLandOwner(uint256 id) public view returns (address) {
        return LandOwner[id];
    }

    function verifySeller(address _sellerId) public isLandInspector {
        SellerVerification[_sellerId] = true;
        emit Verified(_sellerId);
    }

    function rejectSeller(address _sellerId) public isLandInspector {
        SellerRejection[_sellerId] = true;
        emit Rejected(_sellerId);
    }

    function verifyBuyer(address _buyerId) public isLandInspector {
        BuyerVerification[_buyerId] = true;
        emit Verified(_buyerId);
    }

    function rejectBuyer(address _buyerId) public isLandInspector {
        BuyerRejection[_buyerId] = true;
        emit Rejected(_buyerId);
    }

    function verifyLand(uint256 _landId) public isLandInspector {
        LandVerification[_landId] = true;
    }

    function isLandVerified(uint256 _id) public view returns (bool) {
        require(LandVerification[_id]);
        return true;
    }

    function isVerified(address _id) public view returns (bool) {
        require(SellerVerification[_id] || BuyerVerification[_id]);
        return true;
    }

    function isRejected(address _id) public view returns (bool) {
        require(SellerRejection[_id] || BuyerRejection[_id]);
        return true;
    }

    function isSeller(address _id) public view returns (bool) {
        require(RegisteredSellerMapping[_id]);
        return true;
    }

    function isBuyer(address _id) public view returns (bool) {
        require(RegisteredBuyerMapping[_id]);
        return true;
    }

    function isRegistered(address _id) public view returns (bool) {
        require(RegisteredAddressMapping[_id]);
        return true;
    }

    function addLand(
        uint256 _area,
        string memory _city,
        string memory _state,
        uint256 landPrice,
        uint256 _propertyPID
    ) public {
        //Land should be added by verified seller
        require((isSeller(msg.sender)) && (isVerified(msg.sender)));
        landsCount++;
        lands[landsCount] = Landreg(
            landsCount,
            _area,
            _city,
            _state,
            landPrice * 1e18,
            _propertyPID
        );
        LandOwner[landsCount] = msg.sender;
        emit AddingLand(landsCount);
    }

    //Seller Registeration
    function registerSeller(
        string memory _name,
        uint256 _age,
        string memory _aadharNumber,
        string memory _panNumber
    ) public {
        //checking if seller is already registered or not
        require(!RegisteredAddressMapping[msg.sender]);

        RegisteredAddressMapping[msg.sender] = true;
        RegisteredSellerMapping[msg.sender] = true;
        sellersCount++;
        SellerMapping[msg.sender] = Seller(
            msg.sender,
            _name,
            _age,
            _aadharNumber,
            _panNumber
        );
        sellers.push(msg.sender);
        emit Registration(msg.sender);
    }

    function getSellerDetails(address i)
        public
        view
        returns (
            string memory,
            uint256,
            string memory,
            string memory
        )
    {
        return (
            SellerMapping[i].name,
            SellerMapping[i].age,
            SellerMapping[i].aadharNumber,
            SellerMapping[i].panNumber
        );
    }

    function registerBuyer(
        string memory _name,
        uint256 _age,
        string memory _city,
        string memory _aadharNumber,
        string memory _panNumber
    ) public {
        //require that Buyer is not already registered
        require(!RegisteredAddressMapping[msg.sender]);

        RegisteredAddressMapping[msg.sender] = true;
        RegisteredBuyerMapping[msg.sender] = true;
        buyersCount++;
        BuyerMapping[msg.sender] = Buyer(
            msg.sender,
            _name,
            _age,
            _city,
            _aadharNumber,
            _panNumber
        );
        buyers.push(msg.sender);

        emit Registration(msg.sender);
    }

    function getBuyerDetails(address i)
        public
        view
        returns (
            string memory,
            string memory,
            string memory,
            uint256,
            string memory
        )
    {
        return (
            BuyerMapping[i].name,
            BuyerMapping[i].city,
            BuyerMapping[i].panNumber,
            BuyerMapping[i].age,
            BuyerMapping[i].aadharNumber
        );
    }

    function requestLand(address _sellerId, uint256 _landId) public {
        require(isBuyer(msg.sender) && isVerified(msg.sender));

        requestsCount++;
        RequestsMapping[requestsCount] = LandRequest(
            requestsCount,
            _sellerId,
            msg.sender,
            _landId
        );
        RequestStatus[requestsCount] = false;
        RequestedLands[requestsCount] = true;

        emit Landrequested(_sellerId);
    }

    function getRequestDetails(uint256 i)
        public
        view
        returns (
            address,
            address,
            uint256,
            bool
        )
    {
        return (
            RequestsMapping[i].sellerId,
            RequestsMapping[i].buyerId,
            RequestsMapping[i].landId,
            RequestStatus[i]
        );
    }

    function isRequested(uint256 _id) public view returns (bool) {
        require(RequestedLands[_id]);
        return true;
    }

    function isApproved(uint256 _id) public view returns (bool) {
        require(RequestStatus[_id]);
        return true;
    }

    function approveRequest(uint256 _reqId) public {
        require((isSeller(msg.sender)) && (isVerified(msg.sender)));
        RequestStatus[_reqId] = true;
    }

    function LandOwnershipTransfer(uint256 _landId, address _newOwner)
        public
        isLandInspector
    {
        require(isPaid(_landId));
        LandOwner[_landId] = _newOwner;
    }

    function isPaid(uint256 _landId) public view returns (bool) {
        require(PaymentReceived[_landId]);
        return true;
    }

    function payment(address payable _receiver, uint256 _landId)
        public
        payable
    {
        require(
            BuyerVerification[msg.sender] &&
                SellerVerification[msg.sender] &&
                msg.value == lands[_landId].landPrice
        );
        PaymentReceived[_landId] = true;
        _receiver.transfer(msg.value);
    }
}
