const { expect } = require("chai");

describe("Chain Token contract", function () {
	it("Deployment should assign the total supply of tokens to the owner", async function () {
		const [owner] = await ethers.getSigners();

		const ChainToken = await ethers.getContractFactory("BusinessToken");
		const chainToken = await ChainToken.deploy(owner.address, owner.address);

		const ownerBalance = await chainToken.balanceOf(owner.address);
		expect(await chainToken.totalSupply()).to.equal(ownerBalance);
	});
});
