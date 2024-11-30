const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const LoyaltyTokenModule = buildModule("LoyaltyTokenModule", (m) => {
	const account1 = m.getAccount(0);
	const loyaltyToken = m.contract("LoyaltyToken", [account1]);

	return { loyaltyToken };
});

module.exports = LoyaltyTokenModule;
