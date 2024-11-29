const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const LoyaltyTokenModule = buildModule("LoyaltyTokenModule", (m) => {
	const account1 = m.getAccount(0);
	const token = m.contract("LoyaltyToken", [account1, account1]);

	return { token };
});

module.exports = LoyaltyTokenModule;
