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
        const print = await deployer.deploy(CertificatePrint, "100000000000000000", token.address, issuers.address, wallet)

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
            "0x230E277B1A6B36d56Da0F143Fe73ABdA7a926dbb",
            institution.logs[0].args._hash,
            "Solidity Hello World",
            "1 de Outubro de 2018",
            "6",
            "0x0")
        console.log(certificate.logs[0].args)

        await print.printCertificate (
            "Fábio Hildebrand", 
            "fabiohildebrand@gmail.com", 
            "0x230E277B1A6B36d56Da0F143Fe73ABdA7a926dbb",
            institution.logs[0].args._hash,
            "Solidity Hello World Advanced",
            "1 de Novembro de 2018",
            "8",
            "0x0")
  
        return true
    } catch (err) {
        console.log('### error deploying contracts', err)
    }
  }

  const deployContracts = async (deployer, accounts) => {
    try {

        /* token */
        const token = await deployer.deploy(TokenMock)

        /* issuers */
        const issuers = await deployer.deploy(Issuers)


        /* print */
        const print = await deployer.deploy(CertificatePrint, "100000000000000000", token.address, issuers.address, "0x230E277B1A6B36d56Da0F143Fe73ABdA7a926dbb")

        return true
    } catch (err) {
        console.log('### error deploying contracts', err)
    }
  }
  
  
  module.exports = (deployer, network, accounts) => {
      deployer.then(async () => {
          if (deployer.network == "development")
            await deployContractsDevelopment(deployer, accounts)
          else
            await deployContracts(deployer, accounts)
          console.log('### finished deploying contracts')
      })
      .catch(err => console.log('### error deploying contracts', err))
  }