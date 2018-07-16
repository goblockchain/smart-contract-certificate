pragma solidity 0.4.19;

import "./Issuers.sol";

/// @title Contract CertificatePrint, prints the certificates
contract CertificatePrint is Issuers {

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
    }

    // @dev Certificate data mapping for storage
    mapping (bytes32 => Certificate) public certificates;

    // @dev Event fired for every new certificate, to be checked to get all certificates
    event logPrintedCertificate(bytes32 contractAddress, string _name, string email, bytes32 _institution, string _course, string _dates, uint16 _hours);

    function printCertificate (string _name, string _email, bytes32 _institution, string _course, string _dates, uint16 _hours, string instructorName) public onlyInstitution(_institution) returns (bytes32 certificateAddress) {

        // creates certificate address
        certificateAddress = keccak256(block.number, now, msg.data);

        // create certificate data
        certificates[certificateAddress] = Certificate(_name, _email, _institution, _course, _dates, _hours, true, instructorName, msg.sender);

        // creates the event, to be used to query all the certificates
        logPrintedCertificate(certificateAddress, _name, _email, _institution, _course, _dates, _hours);
    }

    // @dev Invalidates a deployed certificate
    function invalidateCertificate(bytes32 _certificateAddress) external onlyCertificateIssuer(_certificateAddress) {
        certificates[_certificateAddress].valid = false;
    }

    // @dev Modifier: allows only if the user has access to institution that issued the certificate
    modifier onlyCertificateIssuer(bytes32 _certificateAddress) {
        bytes32 institution = certificates[_certificateAddress].institution;
        checkRole(msg.sender, institution);
        _;
    }
}
