const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { stringToBytes32, bytes32ToString, printTokenAttrs } = require("./TestUtils");

describe("BusinessChain Contracts", function () {
	async function deployContractsFixture() {
		const [owner, otherAccount] = await ethers.getSigners();

		const BusinessToken = await ethers.getContractFactory("BusinessToken");
		const businessToken = await BusinessToken.deploy(owner.address);
		await businessToken.grantMintRole(owner.address);
		await businessToken.safeMint(owner.address, stringToBytes32("ImageId"), [stringToBytes32("A Shop"), stringToBytes32("Restaurant")]);

		const LoyaltyToken = await ethers.getContractFactory("LoyaltyToken");
		const loyaltyToken = await LoyaltyToken.deploy(owner.address);

		const LoyaltyService = await ethers.getContractFactory("LoyaltyService");
		const loyaltyService = await LoyaltyService.deploy(loyaltyToken);

		return { owner, otherAccount, businessToken, loyaltyToken, loyaltyService };
	}

	describe("Stake Service contract", function () {
		it("Can Stake asset", async function () {
			const { businessToken, owner } = await loadFixture(deployContractsFixture);

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
			const { owner, businessToken, loyaltyToken, loyaltyService } = await loadFixture(deployContractsFixture);

			const ShapeCraftKey = await ethers.getContractFactory("ShapeCraftKey");
			const shapeCraftKey = await ShapeCraftKey.deploy(owner.address);
			let i = 0;
			while (i < 50) {
				await shapeCraftKey.safeMint(owner.address);
				i++;
			}

			await loyaltyService.addCollection(shapeCraftKey);

			await businessToken.addManagedService(0, loyaltyService);
			await loyaltyToken.safeMintNode(
				owner.address,
				stringToBytes32("ImageId"),
				[stringToBytes32("A Shop"), "0x0000000000000000000000000000000000000000000000000000000000000000"],
				0,
				businessToken
			);

			await loyaltyToken.addPoints(0, 0, businessToken.target);
			const points = await loyaltyToken.getTraitValue(0, "0x506f696e74730000000000000000000000000000000000000000000000000000");
			//console.log(points);
			await printTokenAttrs(loyaltyToken, 0);

			await loyaltyToken.redeemPoints(0, 1);
		});
	});
});
