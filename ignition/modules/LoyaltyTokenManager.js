const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const loyaltyTokenModule = require("./LoyaltyToken.js");

const LoyaltyTokenManagerModule = buildModule("LoyaltyTokenManagerModule", (m) => {
	const { loyaltyToken } = m.useModule(loyaltyTokenModule);
	const account1 = m.getAccount(0);
	const loyaltyTokenManager = m.contract("LoyaltyTokenManager", [account1]);

	m.call(loyaltyToken, "grantMintRole", [loyaltyTokenManager]);

	return { loyaltyTokenManager };
});

module.exports = LoyaltyTokenManagerModule;
