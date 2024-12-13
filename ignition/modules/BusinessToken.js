const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const BusinessTokenModule = buildModule("BusinessTokenModule", (m) => {
	const businessToken = m.contract("BusinessToken", []);

	// m.call(businessToken, "safeMint", [
	// 	"0xCe190cab58c6524b7f8e8541bA9Dd0C683bA4dfE",
	// 	"0x427573696e65737350726f76696465722e706e67000000000000000000000000",
	// 	["0x412053686f700000000000000000000000000000000000000000000000000000", "0x412053686f700000000000000000000000000000000000000000000000000000"],
	// ]);

	return { businessToken };
});

module.exports = BusinessTokenModule;
