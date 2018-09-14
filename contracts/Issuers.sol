pragma solidity 0.4.24;

import "./Institutions.sol";

//  @devManages users allowed to issue certificates from a determined institution
contract Issuers is Institutions {

    // @dev Event fired for every new issuer, to be checked to get all issuers
    event logNewInssuer(address _address, bytes32 institution, uint256 timestamp);

    // @dev adds new Issuer to valid Institution
    function addIssuer(address _issuerAddress, bytes32 _institution) public onlyAdmin() {
        require(institutions[_institution].valid = true, "Institution inactive or invalid.");
        addRole(_issuerAddress, _institution);
    }

    // @dev revokes access from Issuer
    function revokeIssuer(address _issuerAddress, bytes32 _institution) public onlyAdmin() {
        removeRole(_issuerAddress, _institution);
    }
}
