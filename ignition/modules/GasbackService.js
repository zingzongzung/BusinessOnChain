const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const config = require("./config/deploy-config.js");
const businessTokenModule = require("./BusinessToken.js");
const partnerServiceModule = require("./PartnerService.js");
const loyaltyServiceModule = require("./LoyaltyService.js");

const GasbackServiceModule = buildModule("GasbackServiceModule", (m) => {
	const { businessToken } = m.useModule(businessTokenModule);
	const { partnerNFTService } = m.useModule(partnerServiceModule);
	const { loyaltyService, loyaltyToken } = m.useModule(loyaltyServiceModule);
	const account1 = m.getAccount(0);
	const gasbackAddress = config.gasbackAddress;

	const gasbackService = m.contract("GasbackService", [gasbackAddress]);

	const registerForGasback = m.call(gasbackService, "registerForGasback", []);

	const tokenId = m.staticCall(gasbackService, "getGasbackServiceTokenId", [], "tokenId", { after: [registerForGasback] });

	const gasback = m.contractAt("IGasback", gasbackAddress);

	m.call(gasback, "assign", [tokenId, businessToken], { id: "assignBusinessToken", after: [tokenId] });
	m.call(gasback, "assign", [tokenId, loyaltyToken], { id: "assignLoyaltyToken", after: [tokenId] });
	m.call(gasback, "assign", [tokenId, partnerNFTService], { id: "assignPartnerNFTService", after: [tokenId] });
	m.call(gasback, "assign", [tokenId, loyaltyService], { id: "assignLoyaltyService", after: [tokenId] });

	return { gasback };
});

module.exports = GasbackServiceModule;
