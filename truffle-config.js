require('dotenv').config()
var HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {

  networks: {
    // Useful for testing. The `development` name is special - truffle uses it by default
    // if it's defined here and no other network is specified at the command line.
    // You should run a client (like ganache-cli, geth or parity) in a separate terminal
    // tab if you use this network and you must also set the `host`, `port` and `network_id`
    // options below to some value.
    //
    dev: {
      host: "127.0.0.1", // Localhost (default: none)
      port: 8545, // Standard Ethereum port (default: none)
      network_id: "*", // Any network (default: none)
    },
    test: {
      host: "127.0.0.1", // Localhost (default: none)
      port: 8545, // Standard Ethereum port (default: none)
      network_id: "*", // Any network (default: none)
    },
    rinkeby: { 
      network_id: 4,
      provider: new HDWalletProvider(process.env.DEV_MNEMONIC, `https://ropsten.infura.io/${process.env.DEV_INFURA}`, 0),
    },
    mainnet: { 
      network_id: 1,
      provider: new HDWalletProvider(process.env.DEV_MNEMONIC, `https://mainnet.infura.io/${process.env.DEV_INFURA}`, 0),
    }
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.5.10", // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: { // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: false,
          runs: 200
        },
        //  evmVersion: "byzantium"
      }
    }
  }
}