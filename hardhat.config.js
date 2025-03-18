require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-verify"); // ✅ Add verification plugin
require("dotenv").config();

const MNEMONIC = process.env.MNEMONIC || "test test test test test test test test test test test junk";

module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    opencampus: {
      url: "https://rpc.open-campus-codex.gelato.digital",
      chainId: 656476,
      accounts: {
        mnemonic: MNEMONIC,
        path: "m/44'/60'/0'/0",
        initialIndex: 0,
        count: 20
      }
    }
  },
  etherscan: {
    apiKey: {
      opencampus: process.env.ETHERSCAN_API_KEY, // Use the API key from .env
    },
    customChains: [
      {
        network: "opencampus",
        chainId: 656476,
        urls: {
          apiURL: "https://opencampus-codex.blockscout.com/api",
          browserURL: "https://opencampus-codex.blockscout.com",
        },
      },
    ],
  },
};
