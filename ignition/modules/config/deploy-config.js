const hre = require("hardhat");

const config = {
	networks: {
		"shape-sepolia": {
			vrfOperator: "0x7Ab2Dca880Cb3fE478a924f72d3381B1835E72bC", //not being used so this is adummy address
			gasbackAddress: "0xdF329d59bC797907703F7c198dDA2d770fC45034",
			adminWallet: "0x30ed1a5FB009d6B68EEf3099239727604541bAd4",
		},
		"shape-mainnet": {
			vrfOperator: "0x7Ab2Dca880Cb3fE478a924f72d3381B1835E72bC", //not being used so this is adummy address
			gasbackAddress: "0xf5e602c87d675E978F097503aedE4A766285a08B",
			adminWallet: "0x30ed1a5FB009d6B68EEf3099239727604541bAd4",
		},
	},
};

const networkName = hre.network.name;
const currentConfig = config.networks[networkName];

module.exports = currentConfig;
