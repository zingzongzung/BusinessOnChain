const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const PartnerServiceModule = buildModule("PartnerServiceModule", (m) => {
	const account1 = m.getAccount(0);

	const partnerNFTService = m.contract("PartnerNFTService", ["0x7Ab2Dca880Cb3fE478a924f72d3381B1835E72bC"]);

	return { partnerNFTService };
});

module.exports = PartnerServiceModule;
