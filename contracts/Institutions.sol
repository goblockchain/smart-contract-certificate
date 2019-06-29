pragma solidity 0.5.10;

import "./RBAC.sol";

//  @devManages institutions allowed to issue certificates
contract Institutions is RBAC {

    // @dev Institution data struct
    struct Institution {
        string code;
        string name;
        uint256 validFrom;
        uint256 validTo;
        bool valid;
    }

    // @dev Institution data mapping for storage
    mapping (bytes32 => Institution) public institutions;

    // @dev Event fired for every new institution, to be checked to get all institutions
    event logNewInstitution(bytes32 _hash, string _code, string _name, uint256 _timestamp);

    function addInstitution (
        string memory _name,
        string memory _code
        ) public onlyAdmin() returns (bytes32 institutionHash) {

        // creates institution hash
        institutionHash = keccak256(abi.encodePacked(block.number, now, msg.data));

        // create institution data
        institutions[institutionHash] = Institution(_code, _name, now, now + 31536000, true);

        // fires the event, to be used to query all the institutions
        emit logNewInstitution(institutionHash, _code, _name, now);
    }

    // @dev Invalidates an institution
    function invalidateInstitution(bytes32 _institutionHash) public onlyAdmin() {
        institutions[_institutionHash].valid = false;
        institutions[_institutionHash].validTo = now;
    }

    function isInstitutionValid(bytes32 _institutionHash) public view returns (bool) {
        return institutions[_institutionHash].valid == true && institutions[_institutionHash].validTo >= now;
    }

    // @dev Modifier to allow only users from a given institution to access functions
    modifier onlyInstitution(bytes32 _institutionHash) {
        checkRole(msg.sender, _institutionHash);
        require(isInstitutionValid(_institutionHash), "Invalid Institution");
        _;
    }

}
