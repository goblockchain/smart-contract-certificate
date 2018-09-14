var CertificatePrint = artifacts.require("./CertificatePrint.sol");
var Issuers = artifacts.require("./Issuers.sol");
var TokenMock = artifacts.require("./TokenMock.sol");

  // for testing only, implments a token with faucet, mints tokens to deployer and creates an allowance for the print contract
  // then it creates an institution, and gives access to it and prints a certificate
  // you can print certificates directly
  const deployContractsDevelopment = async (deployer, accounts) => {
    try {

        const wallet = accounts[0]

        /* token */
        const token = await deployer.deploy(TokenMock)

        /* issuers */
        const issuers = await deployer.deploy(Issuers)

        /* print */
        const print = await deployer.deploy(CertificatePrint, 100000000000000000, token.address, issuers.address, wallet)


        await token.faucet()
        await token.faucet()
        // approving print to consume tokens
        const approval = await token.approve(print.address, "2000000000000000000")

        // creating institution GBC, giving issuer access to it
        const institution = await issuers.addInstitution("Go Blockchain", "GBC")
        const issuer = await issuers.addIssuer(wallet, institution.logs[0].args._hash)

        const test = await issuers.hasRole(wallet, institution.logs[0].args._hash)
        if(test) console.log("acesso concedido")

        const certificate = await print.printCertificate (
            "Fábio Hildebrand", 
            "fabiohildebrand@gmail.com", 
            institution.logs[0].args._hash,
            "Solidity Hello World",
            "1 de Outubro de 2018",
            "6",
            "Fábio Hildebrand",
            0x0)
        console.log(certificate.logs[0].args)
  
        return true
    } catch (err) {
        console.log('### error deploying contracts', err)
    }
  }

  const deployContracts = async (deployer, accounts) => {
    try {

        /* issuers */
        const issuers = await deployer.deploy(Issuers)


        /* print */
        const print = await deployer.deploy(CertificatePrint, 100000000000000000, "0x... TOKEN ADDRESS", "0x... WALLET ADDRESS")

        return true
    } catch (err) {
        console.log('### error deploying contracts', err)
    }
  }
  
  
  module.exports = (deployer, network, accounts) => {
      deployer.then(async () => {
          if (deployer.network == "development" || deployer.network == "rinkeby")
            await deployContractsDevelopment(deployer, accounts)
          else
            await deployContracts(deployer, accounts)
          console.log('### finished deploying contracts')
      })
      .catch(err => console.log('### error deploying contracts', err))
  }