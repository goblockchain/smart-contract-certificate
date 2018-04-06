var CertificatePrint = artifacts.require("./CertificatePrint.sol");

module.exports = function(deployer) {
  deployer.deploy(CertificatePrint);
};
