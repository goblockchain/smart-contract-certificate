pragma solidity 0.5.10;

import "./Institutions.sol";

/**
* @title Issuers
* @dev Manages users allowed to issue certificates from a determined institution
*/
contract Issuers is Institutions {

    // @dev Event fired for every new issuer, to be checked to get all issuers
    event logNewIssuer(address _address, bytes32 _institution, uint256 _timestamp);

    /**
    * @dev adds new Issuer to valid Institution
    * @param _issuerAddress Address to be used for issuing certificates
    * @param _institution Institution allowed (multiple institutions possible)
    */
    function addIssuer(address _issuerAddress, bytes32 _institution) public onlyAdmin() {
        require(institutions[_institution].valid = true, "Institution inactive or invalid.");
        addRole(_issuerAddress, _institution);
        emit logNewIssuer(_issuerAddress, _institution, now);
    }

    /**
    * @dev Revokes access from Issuer
    * @param _issuerAddress Address to be revoked
    * @param _institution Institution to be revoked (only the access to this institution is revoked, revoke others in case of compromised keys)
    */
    function revokeIssuer(address _issuerAddress, bytes32 _institution) public onlyAdmin() {
        removeRole(_issuerAddress, _institution);
    }
}
