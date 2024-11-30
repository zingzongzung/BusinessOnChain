const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const BusinessTokenModule = buildModule("BusinessTokenModule", (m) => {
	const account1 = m.getAccount(0);
	const businessToken = m.contract("BusinessToken", [account1]);

	return { businessToken };
});

module.exports = BusinessTokenModule;
