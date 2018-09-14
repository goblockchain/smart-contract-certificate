pragma solidity 0.4.24;

import "./Issuers.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";

/// @title Contract CertificatePrint, prints the certificates
contract CertificatePrint is Issuers, ERC20 {

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
        address instructorAddress;
        string data;
    }

    // @dev Certificate data mapping for storage
    mapping (bytes32 => Certificate) public certificates;
    uint public price;
    ERC20 tokenContract;
    address wallet;

    // @dev Event fired for every new certificate, to be checked to get all certificates
    event logPrintedCertificate(
        bytes32 contractAddress, 
        string _name, 
        string email, 
        bytes32 _institution, 
        string _course, 
        string _dates,
        uint16 _hours);

    constructor (uint _price, address _token) public {
        tokenContract = ERC20(_token);
        price = _price;
    }

    function printCertificate (
        string _name, 
        string _email, 
        bytes32 _institution, 
        string _course, 
        string _dates, 
        uint16 _hours, 
        string _instructorName, 
        string _data
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
        certificates[certificateAddress] = Certificate(_name, _email, _institution, _course, _dates, _hours, true, _instructorName, msg.sender, _data);

        // creates the event, to be used to query all the certificates
        emit logPrintedCertificate(certificateAddress, _name, _email, _institution, _course, _dates, _hours);
    }

    // @dev Invalidates a deployed certificate
    function invalidateCertificate(bytes32 _certificateAddress) external onlyCertificateIssuer(_certificateAddress) {
        certificates[_certificateAddress].valid = false;
    }

    function updatePrice(uint _newPrice) public onlyAdmin {
        price = _newPrice;
    }

    function updateToken(address _newAddress) public onlyAdmin {
        tokenContract = ERC20(_newAddress);
    }

    // @dev Modifier: allows only if the user has access to institution that issued the certificate
    modifier onlyCertificateIssuer(bytes32 _certificateAddress) {
        bytes32 institution = certificates[_certificateAddress].institution;
        checkRole(msg.sender, institution);
        _;
    }

    // @dev Modifier: allows only if the user has access to institution that issued the certificate
    modifier charge() {
        require(tokenContract.transferFrom(msg.sender, wallet, price), "Token transfer failed. Check balance and approval.");
        _;
    }
}
