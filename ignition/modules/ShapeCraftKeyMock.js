const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const ShapeCraftKeyMockModule = buildModule("ShapeCraftKeyMockModule", (m) => {
	const account1 = m.getAccount(0);
	const shapeCraftKey = m.contract("MockNFT", [account1]);

	let i = 0;
	while (i < 20) {
		m.call(shapeCraftKey, "safeMint", [account1], { id: `SafeMint_${i}` });
		i++;
	}

	return { shapeCraftKey };
});

module.exports = ShapeCraftKeyMockModule;
