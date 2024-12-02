const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const loyaltyTokenModule = require("./LoyaltyToken.js");

const LoyaltyTokenManagerModule = buildModule("LoyaltyTokenManagerModule", (m) => {
	const { loyaltyToken } = m.useModule(loyaltyTokenModule);
	const loyaltyTokenManager = m.contract("LoyaltyTokenManager", [loyaltyToken]);

	m.call(loyaltyToken, "grantMintRole", [loyaltyTokenManager]);

	return { loyaltyTokenManager };
});

module.exports = LoyaltyTokenManagerModule;
