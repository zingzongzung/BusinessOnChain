const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const config = require("./config/deploy-config.js");

const PartnerServiceModule = buildModule("PartnerServiceModule", (m) => {
	const vrfOperatorAddress = config.vrfOperator;

	const partnerNFTService = m.contract("PartnerNFTService", [vrfOperatorAddress]);

	return { partnerNFTService };
});

module.exports = PartnerServiceModule;
