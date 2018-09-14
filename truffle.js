require('dotenv').config()
var HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
  networks: {
    development: {
      host: 'localhost',
      port: 8545,
      gas: 2000000,
      gasPrice: 100000,
      network_id: '*'
    },
    rinkeby: { 
      network_id: 4,
      provider: new HDWalletProvider(process.env.DEV_MNEMONIC, `https://ropsten.infura.io/${process.env.DEV_INFURA}`, 0),
    }
  },
  // compiler: {
  //    solc: "0.4.19"       
  // }
}
