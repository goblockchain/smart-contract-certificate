pragma solidity 0.5.10;

/**
* @title Issuer Interface
* @dev Only functions used by CertificatePrint are included
*/
interface Issuer {
    function checkRole(address addr, bytes32 roleName) external view;
    function isInstitutionValid(bytes32 _institutionHash) external view returns (bool);
}

/**
* @title ERC20
* @dev Only functions used by CertificatePrint are included
*/
interface ERC20 {
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

/**
* @title CertificatePrint
* @dev Prints the certificates
*/
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

    // @dev Event fired for every new certificate, to be checked to get all certificates
    event logPrintedCertificate(
        bytes32 _contractAddress,
        string _name,
        string _email,
        bytes32 _institution,
        string _course,
        string _dates,
        uint16 _hours);

    /**
    * @dev Constructor, sets price, token, wallet and access control state vars
    * @param _price Price per certificate printed/invalidated
    * @param _token Token used to pay for certificates
    * @param _accessControl Contract that manages issuers and institutions
    * @param _wallet Address to which payments are transfered
    */
    constructor (uint _price, address _token, address _accessControl, address _wallet) public {
        tokenContract = ERC20(_token);
        accessControl = Issuer(_accessControl);
        price = _price;
        wallet = _wallet;
    }

    /**
    * @dev Prints a Certificate
    * @param _name Price per certificate printed/invalidated
    * @param _email Token used to pay for certificates
    * @param _institution institution issuing the certificate
    * @param _course Course
    * @param _dates Dates
    * @param _hours Hours
    * @param _instructorName Instructor Name
    * @param _data Anything goes
    */
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

    /**
    * @dev Invalidates a certificate
    * @param _certificateAddress Address of the certificate to be invalidated
    */
    function invalidateCertificate(bytes32 _certificateAddress) external onlyCertificateIssuer(_certificateAddress) charge {
        certificates[_certificateAddress].valid = false;
    }

    /**
    * @dev Updates price
    * @param _newPrice new Price (same decimal places as the token)
    */
    function updatePrice(uint _newPrice) public onlyAdmin {
        price = _newPrice;
    }

    /**
    * @dev Updates token address
    * @param _newAddress new Token Address
    */
    function updateToken(address _newAddress) public onlyAdmin {
        tokenContract = ERC20(_newAddress);
    }

    /**
    * @dev View token address
    */
    function getTokenAddress() public view returns (address) {
        return(address(tokenContract));
    }

    /**
    * @dev Access Control Address
    */
    function accessControlAddress() public view returns (address) {
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
