const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const businessTokenModule = require("./BusinessToken.js");

const BusinessTokenManagerModule = buildModule("BusinessTokenManagerModule", (m) => {
	const { businessToken } = m.useModule(businessTokenModule);
	const businessTokenManager = m.contract("BusinessTokenManager", [businessToken]);

	m.call(businessToken, "grantMintRole", [businessTokenManager]);

	m.call(businessTokenManager, "safeMint", [
		"0xCe190cab58c6524b7f8e8541bA9Dd0C683bA4dfE",
		["0x412053686f700000000000000000000000000000000000000000000000000000", "0x412053686f700000000000000000000000000000000000000000000000000000"],
	]);

	return { businessTokenManager };
});

module.exports = BusinessTokenManagerModule;
