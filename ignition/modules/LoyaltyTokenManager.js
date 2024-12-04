const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const loyaltyTokenModule = require("./LoyaltyToken.js");
const businessTokenModule = require("./BusinessToken.js");

const LoyaltyTokenManagerModule = buildModule("LoyaltyTokenManagerModule", (m) => {
	const { loyaltyToken } = m.useModule(loyaltyTokenModule);
	const { businessToken } = m.useModule(businessTokenModule);
	const loyaltyTokenManager = m.contract("LoyaltyTokenManager", [loyaltyToken]);

	const mintRole = m.call(loyaltyToken, "grantMintRole", [loyaltyTokenManager]);

	const addService = m.call(businessToken, "addService", [0, loyaltyToken], {
		after: [mintRole],
	});

	m.call(
		loyaltyTokenManager,
		"safeMint",
		[
			"0xCe190cab58c6524b7f8e8541bA9Dd0C683bA4dfE",
			"0x4c6f79616c7479536572766963652e706e670000000000000000000000000000",
			["0x412053686f700000000000000000000000000000000000000000000000000000", "0x0000000000000000000000000000000000000000000000000000000000000000"],
			0,
			"0x08dDb08Cf69F64eD8fE302403fAbC267302a0405",
		],
		{
			after: [addService],
		}
	);

	return { loyaltyTokenManager };
});

module.exports = LoyaltyTokenManagerModule;
