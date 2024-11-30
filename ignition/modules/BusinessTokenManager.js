const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const businessTokenModule = require("./BusinessToken.js");

const BusinessTokenManagerModule = buildModule("BusinessTokenManagerModule", (m) => {
	const { businessToken } = m.useModule(businessTokenModule);
	const account1 = m.getAccount(0);
	const businessTokenManager = m.contract("BusinessTokenManager", [account1]);

	m.call(businessToken, "grantMintRole", [businessTokenManager]);

	return { businessTokenManager };
});

module.exports = BusinessTokenManagerModule;
