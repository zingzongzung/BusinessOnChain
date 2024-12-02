const { expect } = require("chai");

describe("Dynamic Token contract", function () {
	it("Deployment should assign the total supply of tokens to the owner", async function () {
		const [owner] = await ethers.getSigners();

		const BusinessToken = await ethers.getContractFactory("BusinessToken");
		const businessToken = await BusinessToken.deploy(owner.address);
		await businessToken.grantMintRole(owner.address);

		const ownerBalance = await businessToken.balanceOf(owner.address);
		expect(await businessToken.totalSupply()).to.equal(ownerBalance);
		console.log(stringToBytes32("A Shop"));
		await businessToken.safeMint(owner.address, [stringToBytes32("A Shop"), stringToBytes32("Restaurant")]);
		console.log(await businessToken.tokenURI(0));

		await printTokenAttrs(businessToken, 0);
	});

	it("Register service with success", async function () {
		const [owner] = await ethers.getSigners();

		//Initialize Business Token and business token manager contract
		const BusinessToken = await ethers.getContractFactory("BusinessToken");
		const businessToken = await BusinessToken.deploy(owner.address);

		const BusinessTokenManager = await ethers.getContractFactory("BusinessTokenManager");
		const businessTokenManager = await BusinessTokenManager.deploy(businessToken.target);

		//Grant mint role to the business manager token contract and mint a token
		await businessToken.grantMintRole(businessTokenManager.target);
		await businessTokenManager.safeMint(owner.address, [stringToBytes32("Name"), stringToBytes32("Restaurant")]);

		const LoyaltyToken = await ethers.getContractFactory("LoyaltyToken");
		const loyaltyToken = await LoyaltyToken.deploy(owner.address);

		const LoyaltyTokenManager = await ethers.getContractFactory("LoyaltyTokenManager");
		const loyaltyTokenManager = await LoyaltyTokenManager.deploy(loyaltyToken.target);

		await loyaltyToken.grantMintRole(loyaltyTokenManager.target);

		await businessToken.addService(0, loyaltyToken.target);

		await loyaltyTokenManager.safeMint(owner.address, [stringToBytes32("A shop Card"), stringToBytes32("0")], 0, businessToken.target);
		await loyaltyTokenManager.safeMint(owner.address, [stringToBytes32("A shop Csard"), stringToBytes32("03")], 0, businessToken.target);

		await printTokenAttrs(loyaltyToken, 1);
	});
});

function stringToBytes32(text) {
	// Check if the string is longer than 32 bytes and truncate if necessary
	if (ethers.toUtf8Bytes(text).length > 32) {
		throw new Error("String too long");
	}
	return ethers.encodeBytes32String(text);
}

function bytes32ToString(bytes) {
	return ethers.decodeBytes32String(bytes);
}

const printTokenAttrs = async (contract, tokenId) => {
	const attributes = await contract.getTokenAttributes();
	for (let atrIndex = 0; atrIndex < attributes.length; atrIndex++) {
		const attr = attributes[atrIndex];
		const key = bytes32ToString(attr);
		const value = bytes32ToString(await contract.getTraitValue(tokenId, attr));
		console.log(`${key}: ${value}`);
	}
};
