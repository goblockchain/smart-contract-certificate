pragma solidity 0.5.0;

contract Issuer {
    function checkRole(address addr, bytes32 roleName) public view;
}

contract CertificateRepository {
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
       public returns (bytes32 certificateAddress);
       
    function invalidateCertificate(bytes32 _certificateAddress) public;
    function getInstitutionCertificate(bytes32 _certificateAddress) public view returns(bytes32);
}

/// @title Contract CertificatePrint, prints the certificates
contract CertificatePrint {

    Issuer accessControl;
    CertificateRepository certificateRepository;
    
    //quantity of certificates to issuer print
    mapping(bytes32 => uint16) public quantityAvalaible;

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

    constructor (address _issuerContract, address _repositoryContract) public {
        accessControl = Issuer(_issuerContract);
        certificateRepository = CertificateRepository(_repositoryContract);

    }

    function printCertificate (
        string memory _name, 
        string memory _email, 
        address _ownerAddress,
        bytes32 _institution, 
        string memory _course, 
        string memory _dates, 
        uint16 _hours, 
        bytes32 _data
        ) 
        public
        checkQuantityAvalaible(_institution)
        onlyInstitution(_institution) {
            
        quantityAvalaible[_institution] = (quantityAvalaible[_institution] - 1);
        // create certificate data
        certificateRepository.printCertificate(_name, _email, _ownerAddress, _institution, _course, _dates, _hours, _data, msg.sender);
    }

    // @dev Invalidates a deployed certificate
    function invalidateCertificate(bytes32 _certificateAddress) external onlyCertificateIssuer(_certificateAddress) {
        certificateRepository.invalidateCertificate(_certificateAddress);
    }

    function updateQuantity(uint16 _newQuantity, bytes32 _institution) public onlyAdmin {
        quantityAvalaible[_institution] = _newQuantity;
    }

    function updateRepository(address _newAddress) public onlyAdmin {
        certificateRepository = CertificateRepository(_newAddress);
    }

    function getRepositoryAddress() public view returns (address) {
        return address(certificateRepository);
    }

    function issuerAddress() public view returns (address) {
        return address(accessControl);
    }

    // @dev Modifier: allows only if the user has access to institution that issued the certificate
    modifier onlyCertificateIssuer(bytes32 _certificateAddress) {
        bytes32 institution = certificateRepository.getInstitutionCertificate(_certificateAddress);
        accessControl.checkRole(msg.sender, institution);
        _;
    }

    // @dev Modifier: allows only if the user has access to institution that issued the certificate
    modifier onlyAdmin() {
        accessControl.checkRole(msg.sender, keccak256(abi.encodePacked(address(accessControl))));
        _;
    }

    // @dev Modifier: allows only if the user has access to institution that issued the certificate
    modifier onlyInstitution(bytes32 _institution) {
        accessControl.checkRole(msg.sender, _institution);
        _;
    }

    // @dev Modifier: allows only if the user has access to institution that issued the certificate
    modifier checkQuantityAvalaible(bytes32 _institution) {
        require (quantityAvalaible[_institution] > 0);
        _;
    }    
    
}