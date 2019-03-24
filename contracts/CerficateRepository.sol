pragma solidity 0.5.0;

contract CertificateRepository {
    address public owner = msg.sender;
    
    // @dev Certificate data struct
    struct Certificate {
        string name;
        string email;
        address ownerAddress;
        bytes32 institution;
        string course;
        string dates;
        uint16 courseHours;
        bool valid;
        address issuerAddress;
    }

    mapping (address => bool) public goBlockchainIssues;    
    
    mapping (bytes32 => bytes32[]) public institutionsCertificates;
    mapping (bytes32 => Certificate) public certificates;
    mapping (bytes32 => bytes32) public certificateData;    
    
    // // @dev Event fired for every new certificate, to be checked to get all certificates
    event logPrintedCertificate(
        bytes32 certificateHash, 
        string name, 
        string email, 
        address ownerAddress,
        bytes32 institution, 
        string course, 
        string dates,
        uint16 _hours
    );
    
    constructor () public {
        goBlockchainIssues[msg.sender] = true;
    }
    
    function printCertificate (
        string memory _name, 
        string memory _email, 
        address _ownerAddress,
        bytes32 _institution, 
        string memory _course, 
        string memory _dates, 
        uint16 _hours, 
        bytes32 _data,
        address _issuerAddress
        ) 
        public
        onlyGOBlockchainIssues
        returns (
            bytes32 certificateAddress
            ) {
        // creates certificate address
        certificateAddress = keccak256(abi.encodePacked(block.number, now, msg.data));

        // create certificate data
        certificates[certificateAddress] = Certificate(_name, _email, _ownerAddress, _institution, _course, _dates, _hours, true, _issuerAddress);
        certificateData[certificateAddress] = _data;
        institutionsCertificates[_institution].push(certificateAddress);
        // creates the event, to be used to query all the certificates
        emit logPrintedCertificate(certificateAddress, _name, _email, _ownerAddress, _institution, _course, _dates, _hours);
    }    

    // @dev Invalidates a deployed certificate
    function invalidateCertificate(bytes32 _certificateAddress) public onlyGOBlockchainIssues {
        certificates[_certificateAddress].valid = false;
    }
    
    // @dev Modifier: allows only if the user has access to institution that issued the certificate
    modifier onlyGOBlockchainIssues() {
        require (goBlockchainIssues[msg.sender]);
        _;
    }
    
    function addIssueContract(address _issueAddress) public returns (bool){
        require(msg.sender == owner);
        goBlockchainIssues[_issueAddress] = true;
        return true;
    }
    
    function removeAdmin(address _issueAddress) public returns (bool){
        require(msg.sender == owner);
        goBlockchainIssues[_issueAddress] = false;
        return true;
    }
    
    function getCertificates(bytes32 _institution) public view returns(bytes32[] memory){
        return institutionsCertificates[_institution];
    }
    
    function getInstitutionCertificate(bytes32 _certificateAddress) public view returns(bytes32){
        return certificates[_certificateAddress].institution;
    }    
}

