var CertificatePrint = artifacts.require("./CertificatePrint.sol");
var Institutions = artifacts.require("./Institutions.sol");
var TokenMock = artifacts.require("./TokenMock.sol");

//production migration
// module.exports = function(deployer) {
//   deployer.deploy(CertificatePrint, "100000000000", "0x0");
// };






// Migrations for testing, includes tokenmock, mints tokens to msg.sender
  const deployContracts = async (deployer, accounts) => {
    try {

        /* token */
        const token = await deployer.deploy(TokenMock)
        await token.faucet()
        await token.faucet()

        /* print */
        const print = await deployer.deploy(CertificatePrint, 100000000000000000, token.address)


        // approving print to consume tokens
        await token.approve(print.address, "2000000000000000000")
  
        return true
    } catch (err) {
        console.log('### error deploying contracts', err)
    }
  }
  
  
  module.exports = (deployer, network, accounts) => {
      deployer.then(async () => {
          await deployContracts(deployer, accounts)
          console.log('### finished deploying contracts')
      })
      .catch(err => console.log('### error deploying contracts', err))
  }