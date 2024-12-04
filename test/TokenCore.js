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

		const NodeToken = await ethers.getContractFactory("BusinessTokenV2");
		const nodeToken = await NodeToken.deploy(owner.address);
		await nodeToken.grantMintRole(owner.address);

		await nodeToken.safeMintRoot(owner.address, stringToBytes32("ImageId"), [stringToBytes32("A Shop"), stringToBytes32("Restaurant")]);

		const ServiceToken = await ethers.getContractFactory("ServiceTokenV2");
		const serviceToken = await ServiceToken.deploy(owner.address);
		//await serviceToken.grantMintRole(owner.address);

		//await serviceToken.safeMintRoot(owner.address, stringToBytes32("ImageId"), [stringToBytes32("A Shop"), stringToBytes32("Restaurant")]);

		await nodeToken.addService(0, serviceToken);

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

describe("Dynamic Token contract", function () {
	it("Deployment should assign the total supply of tokens to the owner", async function () {
		const [owner] = await ethers.getSigners();

		const BusinessToken = await ethers.getContractFactory("BusinessToken");
		const businessToken = await BusinessToken.deploy(owner.address);
		await businessToken.grantMintRole(owner.address);

		const ownerBalance = await businessToken.balanceOf(owner.address);
		expect(await businessToken.totalSupply()).to.equal(ownerBalance);
		await businessToken.safeMint(owner.address, stringToBytes32("ImageId"), [stringToBytes32("A Shop"), stringToBytes32("Restaurant")]);

		await printTokenAttrs(businessToken, 0);
	});

	it("Register service with success2", async function () {
		const [owner] = await ethers.getSigners();

		//Initialize Business Token and business token manager contract
		const BusinessToken = await ethers.getContractFactory("BusinessToken");
		const businessToken = await BusinessToken.deploy(owner.address);

		const BusinessTokenManager = await ethers.getContractFactory("BusinessTokenManager");
		const businessTokenManager = await BusinessTokenManager.deploy(businessToken.target);

		//Grant mint role to the business manager token contract and mint a token
		await businessToken.grantMintRole(businessTokenManager.target);
		await businessTokenManager.safeMint(owner.address, stringToBytes32("ImageId"), [stringToBytes32("Name"), stringToBytes32("Restaurant")]);

		const LoyaltyToken = await ethers.getContractFactory("LoyaltyToken");
		const loyaltyToken = await LoyaltyToken.deploy(owner.address);

		const LoyaltyTokenManager = await ethers.getContractFactory("LoyaltyTokenManager");
		const loyaltyTokenManager = await LoyaltyTokenManager.deploy(loyaltyToken.target);

		await loyaltyToken.grantMintRole(loyaltyTokenManager.target);

		await businessToken.addService(0, loyaltyToken.target);

		await loyaltyTokenManager.safeMint(
			owner.address,
			stringToBytes32("ImageId"),
			[stringToBytes32("A shop Card"), stringToBytes32("0")],
			0,
			businessToken.target
		);

		await loyaltyTokenManager.safeMint(
			owner.address,
			stringToBytes32("BusinessProvider.png"),
			[stringToBytes32("A shop Csard"), stringToBytes32("03")],
			0,
			businessToken.target
		);

		//await printTokenAttrs(loyaltyToken, 1);
	});

	it("Cant redeem if you are not the owner", async function () {
		const [owner, otherAccount] = await ethers.getSigners();

		//Initialize Business Token and business token manager contract
		const BusinessToken = await ethers.getContractFactory("BusinessToken");
		const businessToken = await BusinessToken.deploy(owner.address);

		const BusinessTokenManager = await ethers.getContractFactory("BusinessTokenManager");
		const businessTokenManager = await BusinessTokenManager.deploy(businessToken.target);

		//Grant mint role to the business manager token contract and mint a token
		await businessToken.grantMintRole(businessTokenManager.target);
		await businessTokenManager.safeMint(owner.address, stringToBytes32("ImageId"), [stringToBytes32("Name"), stringToBytes32("Restaurant")]);

		const LoyaltyToken = await ethers.getContractFactory("LoyaltyToken");
		const loyaltyToken = await LoyaltyToken.deploy(owner.address);

		const LoyaltyTokenManager = await ethers.getContractFactory("LoyaltyTokenManager");
		const loyaltyTokenManager = await LoyaltyTokenManager.deploy(loyaltyToken.target);

		await loyaltyToken.grantMintRole(loyaltyTokenManager.target);

		await businessToken.addService(0, loyaltyToken.target);

		await loyaltyTokenManager.safeMint(
			owner.address,
			stringToBytes32("ImageId"),
			[stringToBytes32("A shop Card"), "0x0000000000000000000000000000000000000000000000000000000000000000"],
			0,
			businessToken.target
		);

		let points = await loyaltyToken.getTraitValue(0, stringToBytes32("Points"));

		await loyaltyTokenManager.addPoints(0, 0, businessToken.target);
		await loyaltyTokenManager.addPoints(0, 0, businessToken.target);
		await loyaltyTokenManager.addPoints(0, 0, businessToken.target);

		points = await loyaltyToken.getTraitValue(0, stringToBytes32("Points"));

		await loyaltyTokenManager.redeemPoints(0, 2);
		points = await loyaltyToken.getTraitValue(0, stringToBytes32("Points"));

		await expect(loyaltyTokenManager.connect(otherAccount).redeemPoints(0, 1)).to.be.revertedWithCustomError(loyaltyTokenManager, "TokenNotOwned");

		//await printTokenAttrs(loyaltyToken, 1);
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
