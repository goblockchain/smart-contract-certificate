pragma solidity 0.5.10;

contract Issuer {

    function checkRole(address addr, bytes32 roleName) public view;
    function isInstitutionValid(bytes32 _institutionHash) public view returns (bool);
}

contract ERC20 {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
}

/// @title Contract CertificatePrint, prints the certificates
contract CertificatePrint {

    // @dev Certificate data struct
    struct Certificate {
        string name;
        string email;
        bytes32 institution;
        string course;
        string dates;
        uint16 courseHours;
        bool valid;
        string instructorName;
        address issuerAddress;
    }

    mapping (bytes32 => Certificate) public certificates;
    mapping (bytes32 => bytes32) public certificateData;
    uint public price;
    ERC20 tokenContract;
    Issuer accessControl;
    address wallet;

    // // @dev Event fired for every new certificate, to be checked to get all certificates
    event logPrintedCertificate(
        bytes32 _contractAddress,
        string _name,
        string _email,
        bytes32 _institution,
        string _course,
        string _dates,
        uint16 _hours);

    constructor (uint _price, address _token, address _accessControl, address _wallet) public {
        tokenContract = ERC20(_token);
        accessControl = Issuer(_accessControl);
        price = _price;
        wallet = _wallet;
    }

    function printCertificate (
        string memory _name,
        string memory _email,
        bytes32 _institution,
        string memory _course,
        string memory _dates,
        uint16 _hours,
        string memory _instructorName,
        bytes32 _data
        )
        public
        charge
        onlyInstitution(_institution)
        returns (
            bytes32 certificateAddress
            ) {
        // creates certificate address
        certificateAddress = keccak256(abi.encodePacked(block.number, now, msg.data));

        // create certificate data
        certificates[certificateAddress] = Certificate(_name, _email, _institution, _course, _dates, _hours, true, _instructorName, msg.sender);
        certificateData[certificateAddress] = _data;

        // creates the event, to be used to query all the certificates
        emit logPrintedCertificate(certificateAddress, _name, _email, _institution, _course, _dates, _hours);
    }

    // @dev Invalidates a deployed certificate
    function invalidateCertificate(bytes32 _certificateAddress) external onlyCertificateIssuer(_certificateAddress) charge {
        certificates[_certificateAddress].valid = false;
    }

    function updatePrice(uint _newPrice) public onlyAdmin {
        price = _newPrice;
    }

    function updateToken(address _newAddress) public onlyAdmin {
        tokenContract = ERC20(_newAddress);
    }

    function getTokenAddress() public view returns (address) {
        return(address(tokenContract));
    }

    function issuerAddress() public view returns (address) {
        return(address(accessControl));
    }

    // @dev Modifier: allows only if the user has access to institution that issued the certificate
    modifier onlyCertificateIssuer(bytes32 _certificateAddress) {
        bytes32 institution = certificates[_certificateAddress].institution;
        accessControl.checkRole(msg.sender, institution);
        _;
    }

    // @dev Modifier: allows only if the user has access to institution that issued the certificate
    modifier onlyAdmin() {
        accessControl.checkRole(msg.sender, bytes32("admin"));
        _;
    }

    // @dev Modifier: allows only if the user has access to institution that issued the certificate
    modifier onlyInstitution(bytes32 _institution) {
        accessControl.checkRole(msg.sender, _institution);
        require(accessControl.isInstitutionValid(_institution), "Invalid institution");
        _;
    }

    // @dev Modifier: allows only if the user has access to institution that issued the certificate
    modifier charge() {
        require(tokenContract.transferFrom(msg.sender, wallet, price), "Token transfer failed. Check balance and approval.");
        _;
    }
}
