pragma solidity 0.4.19;

import "./Institutions.sol";

//  @devManages users allowed to issue certificates from a determined institution
contract Issuers is Institutions {

    // @dev Event fired for every new issuer, to be checked to get all issuers
    event logNewInssuer(address _address, bytes32 institution, uint256 timestamp);

    // @dev adds new Issuer to valid Institution
    function addIssuer(address _issuerAddress, bytes32 _institution) public onlyRole("GBC_ADMIN") {
        require(institutions[_institution].valid = true);
        addRole(_issuerAddress, institutions[_institution].code);
    }

    // @dev revokes access from Issuer
    function revokeIssuer(address _issuerAddress, bytes32 _institution) public onlyRole("GBC_ADMIN") {
        removeRole(_issuerAddress, institutions[_institution].code);
    }
}
