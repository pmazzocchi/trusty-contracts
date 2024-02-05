require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: ".env" });

const INFURA_API_KEY = process.env.INFURA_API_KEY;
const QUICKNODE_HTTP_URL = process.env.QUICKNODE_HTTP_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const etherscanKey = process.env.ETHERSCAN_API_KEY;

module.exports = {
  solidity: "0.8.13",
  networks: {
    mainnet: {
      chainId: 1,
      url: `https://mainnet.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [PRIVATE_KEY]
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [PRIVATE_KEY],
    },
    sepolia: {
      url: `https://sepolia.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [PRIVATE_KEY],
    },
    mumbai: {
      url: QUICKNODE_HTTP_URL,
      accounts: [PRIVATE_KEY],
		},
  },
  etherscan: {
    apiKey: {
      goerli: etherscanKey
    }
  }
};