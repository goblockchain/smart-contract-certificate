require('dotenv').config()
var HDWalletProvider = require("truffle-hdwallet-provider");

console.log(process.env.DEV_INFURA)
module.exports = {
  networks: {
    development: {
      host: 'localhost',
      port: 8545,
      gas: 2000000,
      gasPrice: 100000,
      network_id: 5777
    },
    rinkeby: { 
      network_id: 4,
      // must be a thunk, otherwise truffle commands may hang in CI
      provider: () =>
        new HDWalletProvider(process.env.DEV_MNEMONIC, `https://rinkeby.infura.io/v3/${process.env.DEV_INFURA}`),
      network_id: '4',
    },
    mainnet: { 
      network_id: 1,
      provider: new HDWalletProvider(process.env.DEV_MNEMONIC, `https://mainnet.infura.io/v3/${process.env.DEV_INFURA}`, 0),
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 300
    }
  }
}
