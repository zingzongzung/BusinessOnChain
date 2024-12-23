/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-toolbox");

// Ensure your configuration variables are set before executing the script
const { vars } = require("hardhat/config");

// Go to https://infura.io, sign up, create a new API key
// in its dashboard, and add it to the configuration variables
//npx hardhat vars set INFURA_API_KEY
const ALCHEMY_API_KEY = vars.get("ALCHEMY_API_KEY");

// Add your Sepolia account private key to the configuration variables
// To export your private key from Coinbase Wallet, go to
// Settings > Developer Settings > Show private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Beware: NEVER put real Ether into testing accounts
//npx hardhat vars set FUJI_PRIVATE_KEY
const SHAPE_PK = vars.get("SHAPE_PK");

const SHAPE_TESTNET_RPC_URL = "https://shape-sepolia.g.alchemy.com/v2/" + ALCHEMY_API_KEY;
const SEPOLIA_TESTNET_RPC_URL = "https://eth-sepolia.g.alchemy.com/v2/" + ALCHEMY_API_KEY;
const SHAPE_MAINNET_RPC_URL = "https://shape-mainnet.g.alchemy.com/v2/" + ALCHEMY_API_KEY;

module.exports = {
	solidity: "0.8.27",
	networks: {
		"shape-mainnet": {
			url: SHAPE_MAINNET_RPC_URL, // Shape Testnet RPC URL
			chainId: 360, // Shape Testnet Network ID
			accounts: [SHAPE_PK],
		},
		"shape-sepolia": {
			url: SHAPE_TESTNET_RPC_URL, // Shape Testnet RPC URL
			chainId: 11011, // Shape Testnet Network ID
			accounts: [SHAPE_PK],
		},
		sepolia: {
			url: SEPOLIA_TESTNET_RPC_URL, // Shape Testnet RPC URL
			chainId: 11155111, // Shape Testnet Network ID
			accounts: [SHAPE_PK],
		},
	},
	etherscan: {
		apiKey: {
			"shape-mainnet": "empty",
		},
		customChains: [
			{
				network: "shape-mainnet",
				chainId: 360,
				urls: {
					apiURL: "https://shapescan.xyz/api",
					browserURL: "https://shapescan.xyz",
				},
			},
		],
	},
};
