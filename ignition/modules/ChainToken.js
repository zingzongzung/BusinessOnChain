const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const TokenModule = buildModule("ChainTokenModule", (m) => {
	const account1 = m.getAccount(1);
	const token = m.contract("ChainToken", [account1, account1]);

	return { token };
});

module.exports = TokenModule;
