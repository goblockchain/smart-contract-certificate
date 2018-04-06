pragma solidity 0.4.19;

import "../node_modules/zeppelin-solidity/contracts/ownership/rbac/RBAC.sol";

// @dev Usinc OpenZeppelin RBAC for access control
contract accessControl is RBAC {

    // @dev constructor: Assigns admin profile to contract deployer
    // @dev admin can give access to other admins (profile GBC_ADMIN) and other profiles
    function accessControl () public {
        addRole(msg.sender, "GBC_ADMIN");
    }
}
