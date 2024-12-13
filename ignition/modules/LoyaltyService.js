const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const LoyaltyServiceModule = buildModule("LoyaltyServiceModule", (m) => {
	const account1 = m.getAccount(0);

	const loyaltyToken = m.contract("LoyaltyToken", []);

	const loyaltyService = m.contract("LoyaltyService", [account1, loyaltyToken]);

	// const addService = m.call(businessToken, "addManagedService", [0, loyaltyService], {
	// 	//after: [mintRole],
	// });

	//Remove mint from deploy
	// m.call(
	// 	loyaltyToken,
	// 	"safeMint",
	// 	[
	// 		"0xCe190cab58c6524b7f8e8541bA9Dd0C683bA4dfE",
	// 		"0x4c6f79616c7479536572766963652e706e670000000000000000000000000000",
	// 		["0x412053686f700000000000000000000000000000000000000000000000000000", "0x0000000000000000000000000000000000000000000000000000000000000000"],
	// 		0,
	// 		businessToken,
	// 	],
	// 	{
	// 		after: [addService],
	// 	}
	// );

	return { loyaltyService, loyaltyToken };
});

module.exports = LoyaltyServiceModule;
