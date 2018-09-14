pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
//import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

// Mockup token contract built for testing the Certificate issuer.
// Standard ERC20 implementation from OpenZeppelin

// Added faucet functionality to enable testing

contract TokenMock is ERC20 {

    string public constant name = "Go Blockchain";
    string public constant symbol = "GBC";
    uint8 public constant decimals = 18;

    // self service minting, to allow for easy testing.
    function faucet() public returns (bool) {
        _mint(msg.sender, 1000 * uint(10)**decimals);
        return true;
    }

}