const hre = require("hardhat");

const config = {
	networks: {
		"shape-sepolia": {
			vrfOperator: "0x7Ab2Dca880Cb3fE478a924f72d3381B1835E72bC",
			gasbackAddress: "0xdF329d59bC797907703F7c198dDA2d770fC45034",
			adminWallet: "0x30ed1a5FB009d6B68EEf3099239727604541bAd4",
		},
		shape: {
			vrfOperator: "?",
			gasbackAddress: "?",
			adminWallet: "0x30ed1a5FB009d6B68EEf3099239727604541bAd4",
		},
	},
};

const networkName = hre.network.name;
const currentConfig = config.networks[networkName];

module.exports = currentConfig;
