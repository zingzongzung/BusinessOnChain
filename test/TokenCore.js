const { expect } = require("chai");

describe("Dynamic Token contract", function () {
	it("Deployment should assign the total supply of tokens to the owner", async function () {
		const [owner] = await ethers.getSigners();

		const BusinessToken = await ethers.getContractFactory("BusinessToken");
		const businessToken = await BusinessToken.deploy(owner.address, owner.address);

		const ownerBalance = await businessToken.balanceOf(owner.address);
		expect(await businessToken.totalSupply()).to.equal(ownerBalance);

		await businessToken.safeMint(owner.address, [stringToBytes32("Name")]);
		const tokenURI = await businessToken.tokenURI(0);
		console.log(tokenURI);

		const attributes = await businessToken.getTokenAttributes(0);
		attributes.forEach((attr) => console.log(bytes32ToString(attr)));
	});

	it("Register service with success", async function () {
		const [owner] = await ethers.getSigners();

		const BusinessToken = await ethers.getContractFactory("BusinessToken");
		const businessToken = await BusinessToken.deploy(owner.address, owner.address);

		const ownerBalance = await businessToken.balanceOf(owner.address);
		expect(await businessToken.totalSupply()).to.equal(ownerBalance);

		await businessToken.safeMint(owner.address, [stringToBytes32("Name")]);

		const LoyaltyToken = await ethers.getContractFactory("LoyaltyToken");
		const loyaltyToken = await LoyaltyToken.deploy(owner.address, owner.address);

		await loyaltyToken.safeMint(owner.address, [stringToBytes32("Name")]);

		await businessToken.addService(0, loyaltyToken.target);
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
