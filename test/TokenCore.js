const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Stake Service contract", function () {
	it("Can Stake asset", async function () {
		const [owner] = await ethers.getSigners();

		const BusinessToken = await ethers.getContractFactory("BusinessToken");
		const businessToken = await BusinessToken.deploy(owner.address);
		await businessToken.grantMintRole(owner.address);

		await businessToken.safeMint(owner.address, stringToBytes32("ImageId"), [stringToBytes32("A Shop"), stringToBytes32("Restaurant")]);

		const StakingService = await ethers.getContractFactory("StakingService");
		const stakingService = await StakingService.deploy();

		await businessToken.approve(stakingService, 0);
		await stakingService.stakeNFT(businessToken, 0);

		const stakingAccountBalance = await businessToken.balanceOf(stakingService);
		expect(await businessToken.totalSupply()).to.equal(stakingAccountBalance);

		await stakingService.unStakeNFT(businessToken, 0);

		const ownerBalance = await businessToken.balanceOf(owner);
		expect(await businessToken.totalSupply()).to.equal(ownerBalance);
	});
});

describe("Node Token", function () {
	it("Can Mint Token and Child Token", async function () {
		const [owner, otherAccount] = await ethers.getSigners();

		const NodeToken = await ethers.getContractFactory("BusinessToken");
		const nodeToken = await NodeToken.deploy(owner.address);
		await nodeToken.grantMintRole(owner.address);

		await nodeToken.safeMintRoot(owner.address, stringToBytes32("ImageId"), [stringToBytes32("A Shop"), stringToBytes32("Restaurant")]);

		const ServiceToken = await ethers.getContractFactory("LoyaltyToken");
		const serviceToken = await ServiceToken.deploy(owner.address);
		//await serviceToken.grantMintRole(owner.address);

		//await serviceToken.safeMintRoot(owner.address, stringToBytes32("ImageId"), [stringToBytes32("A Shop"), stringToBytes32("Restaurant")]);

		await nodeToken.allowChildNodeManagement(0, serviceToken);

		await serviceToken.safeMintNode(
			owner.address,
			stringToBytes32("ImageId"),
			[stringToBytes32("A Shop"), "0x0000000000000000000000000000000000000000000000000000000000000000"],
			0,
			nodeToken
		);

		await serviceToken.addPoints(0, 0, nodeToken.target);
		await serviceToken.redeemPoints(0, 1);
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
