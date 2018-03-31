pragma solidity ^0.4.18;

import './CertificatePrintAuthorizer.sol';

/// @title ERC20 interface 
contract ERC20 {
    function balanceOf(address guy) public view returns (uint);
    function transfer(address dst, uint wad) public returns (bool);
}

/// @title Contract CertificatePrint, prints the certificates
contract CertificatePrint is CertificateAuthorizer {

    struct Certificate {
        string name;
        string email;
        string institution;
        string course;
        string dates;
        uint16 courseHours;
        bool valid;

    }
    
    mapping (bytes32 => Certificate) public certificates;
    event logPrintedCertificate(bytes32 contractAddress, string _name, string email, string _institution, string _course, string _dates, uint16 _hours);

    function printCertificate (string _name, string _email, string _institution, string _course, string _dates, uint16 _hours) public returns (bytes32 _certificateAddress) {

        // creates certificate smart contract
        bytes32 certificateAddress = keccak256(block.number, now, msg.data);

        // create certificate data
        certificates[certificateAddress] = Certificate(_name, _email, _institution, _course, _dates, _hours, true);
        
        // creates the event, to be used to query all the certificates
        logPrintedCertificate(certificateAddress, _name, _email, _institution, _course, _dates, _hours);

        return certificateAddress;
    }
    
    // @dev Invalidates a deployed certificate
    function invalidateCertificate(bytes32 _certificateAddress) external  {
        certificates[_certificateAddress].valid = false;
    }

}