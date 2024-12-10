const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { stringToBytes32, bytes32ToString } = require("./TestUtils");

describe("BusinessChain Contracts", function () {
	async function deployContractsFixture() {
		const [owner, otherAccount] = await ethers.getSigners();

		const BusinessToken = await ethers.getContractFactory("BusinessToken");
		const businessToken = await BusinessToken.deploy(owner.address);
		await businessToken.grantMintRole(owner.address);

		const LoyaltyToken = await ethers.getContractFactory("LoyaltyToken");
		const loyaltyToken = await LoyaltyToken.deploy(owner.address);

		const LoyaltyService = await ethers.getContractFactory("LoyaltyService");
		const loyaltyService = await LoyaltyService.deploy(owner, loyaltyToken);

		return { owner, otherAccount, businessToken, loyaltyToken, loyaltyService };
	}

	async function deployMockNFTContractFixture() {
		const [owner, otherAccount, mockNFTOwner] = await ethers.getSigners();
		const MockNFT = await ethers.getContractFactory("MockNFT");
		const mockNFT = await MockNFT.deploy(owner.address);
		let i = 0;
		while (i < 50) {
			await mockNFT.safeMint(mockNFTOwner.address);
			i++;
		}

		return { mockNFT, mockNFTOwner };
	}

	describe("Stake Service contract", function () {
		it("Can Stake asset", async function () {
			const { businessToken, owner } = await loadFixture(deployContractsFixture);

			const StakingService = await ethers.getContractFactory("StakingService");
			const stakingService = await StakingService.deploy();

			await businessToken.safeMint(owner.address, stringToBytes32("ImageId"), [stringToBytes32("A Shop"), stringToBytes32("Restaurant")]);

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
		it("Can Mint Root Token", async function () {
			const { owner, otherAccount, businessToken, loyaltyToken, loyaltyService } = await loadFixture(deployContractsFixture);

			await businessToken.safeMint(owner.address, stringToBytes32("ImageId"), [stringToBytes32("A Shop"), stringToBytes32("Restaurant")]);

			const ownerBalance = await businessToken.balanceOf(owner);
			expect(await businessToken.totalSupply()).to.equal(ownerBalance);
		});

		it("Can Add Service to Root Token", async function () {
			const { owner, otherAccount, businessToken, loyaltyToken, loyaltyService } = await loadFixture(deployContractsFixture);

			await businessToken.safeMint(owner.address, stringToBytes32("ImageId"), [stringToBytes32("A Shop"), stringToBytes32("Restaurant")]);

			await businessToken.addManagedService(0, loyaltyService);
		});

		it("Can Mint Child token to other Account", async function () {
			const { owner, otherAccount, businessToken, loyaltyToken, loyaltyService } = await loadFixture(deployContractsFixture);

			await businessToken.safeMint(owner.address, stringToBytes32("ImageId"), [stringToBytes32("A Shop"), stringToBytes32("Restaurant")]);

			await businessToken.addManagedService(0, loyaltyService);

			await loyaltyToken.safeMint(
				otherAccount.address,
				stringToBytes32("ImageId"),
				[stringToBytes32("A Shop"), "0x0000000000000000000000000000000000000000000000000000000000000000"],
				0,
				businessToken
			);

			const otherAccountBalance = await loyaltyToken.balanceOf(otherAccount);
			expect(await loyaltyToken.totalSupply()).to.equal(otherAccountBalance);
		});

		it("Can Add Points with no multiplier", async function () {
			const { owner, businessToken, loyaltyToken, loyaltyService } = await loadFixture(deployContractsFixture);
			await businessToken.safeMint(owner.address, stringToBytes32("ImageId"), [stringToBytes32("A Shop"), stringToBytes32("Restaurant")]);
			await businessToken.addManagedService(0, loyaltyService);
			await loyaltyToken.safeMint(
				owner.address,
				stringToBytes32("ImageId"),
				[stringToBytes32("A Shop"), "0x0000000000000000000000000000000000000000000000000000000000000000"],
				0,
				businessToken
			);

			await loyaltyToken.addPoints(0, 0, businessToken.target);

			expect(await loyaltyToken.getTraitValue(0, "0x506f696e74730000000000000000000000000000000000000000000000000000")).to.equal(
				"0x0000000000000000000000000000000000000000000000000000000000000001"
			);

			await loyaltyToken.redeemPoints(0, 1);
		});

		it("Can Add Points with multiplier 3", async function () {
			const { owner, businessToken, loyaltyToken, loyaltyService } = await loadFixture(deployContractsFixture);
			const { mockNFT: shapeCraftKey, mockNFTOwner } = await loadFixture(deployMockNFTContractFixture);

			await businessToken.safeMint(owner.address, stringToBytes32("ImageId"), [stringToBytes32("A Shop"), stringToBytes32("Restaurant")]);

			await loyaltyService.addCollection(shapeCraftKey);
			await businessToken.addManagedService(0, loyaltyService);

			await loyaltyToken.safeMint(
				mockNFTOwner.address,
				stringToBytes32("ImageId"),
				[stringToBytes32("A Shop"), "0x0000000000000000000000000000000000000000000000000000000000000000"],
				0,
				businessToken
			);

			await loyaltyToken.addPoints(0, 0, businessToken);

			expect(await loyaltyToken.getTraitValue(0, "0x506f696e74730000000000000000000000000000000000000000000000000000")).to.equal(
				"0x0000000000000000000000000000000000000000000000000000000000000004"
			);
		});

		it("Can return father token from the node", async function () {
			const { owner, businessToken, loyaltyToken, loyaltyService, otherAccount } = await loadFixture(deployContractsFixture);
			await businessToken.safeMint(owner.address, stringToBytes32("ImageId"), [stringToBytes32("A Shop"), stringToBytes32("Restaurant")]);

			await businessToken.addManagedService(0, loyaltyService);
			await loyaltyToken.safeMint(
				otherAccount,
				stringToBytes32("ImageId"),
				[stringToBytes32("A Shop"), "0x0000000000000000000000000000000000000000000000000000000000000000"],
				0,
				businessToken
			);

			const tokenId = await loyaltyToken.getTraitValue(0, "0x4661746865722049640000000000000000000000000000000000000000000000");
			const tokenAddressHex = await loyaltyToken.getTraitValue(0, "0x4661746865722041646472657373000000000000000000000000000000000000");
			const tokenAddress = "0x" + tokenAddressHex.slice(26);

			expect(tokenId).to.equal("0x0000000000000000000000000000000000000000000000000000000000000000");
			expect(tokenAddress.toLowerCase()).to.equal(businessToken.target.toLowerCase());
		});
	});

	describe("Partner NFT Service ", function () {
		async function deployPartnerNFTFixture() {
			const [owner, otherAccount] = await ethers.getSigners();

			const PartnerNFTService = await ethers.getContractFactory("PartnerNFTService");
			const partnerNFTService = await PartnerNFTService.deploy(owner);
			return { partnerNFTService };
		}

		it("Can Receive Bulk tokens", async function () {
			const { owner, otherAccount, businessToken, loyaltyToken, loyaltyService } = await loadFixture(deployContractsFixture);
			const { partnerNFTService } = await loadFixture(deployPartnerNFTFixture);
			const { mockNFT: partnerNFT, mockNFTOwner: partnerNFTOwner } = await loadFixture(deployMockNFTContractFixture);

			await businessToken.safeMint(owner.address, stringToBytes32("ImageId"), [stringToBytes32("A Shop"), stringToBytes32("Restaurant")]);

			await partnerNFT.connect(partnerNFTOwner).setApprovalForAll(partnerNFTService, true);
			await partnerNFTService.connect(partnerNFTOwner).bulkReceive(partnerNFT, [0, 1, 2, 3, 4], 0, businessToken);
		});

		it("Can List Received Tokens", async function () {
			const { owner, otherAccount, businessToken, loyaltyToken, loyaltyService } = await loadFixture(deployContractsFixture);
			const { partnerNFTService } = await loadFixture(deployPartnerNFTFixture);
			const { mockNFT: partnerNFT, mockNFTOwner: partnerNFTOwner } = await loadFixture(deployMockNFTContractFixture);

			await businessToken.safeMint(owner.address, stringToBytes32("ImageId"), [stringToBytes32("A Shop"), stringToBytes32("Restaurant")]);

			const givenPartnerTokenIds = [0n, 1n, 2n, 3n, 4n];
			await partnerNFT.connect(partnerNFTOwner).setApprovalForAll(partnerNFTService, true);
			await partnerNFTService.connect(partnerNFTOwner).bulkReceive(partnerNFT, givenPartnerTokenIds, 0, businessToken);

			const address = (await partnerNFTService.getPartnerNftAddresses(businessToken, 0))[0];

			const tokenIds = await partnerNFTService.getPartnerNFTTokenIds(address, businessToken, 0);
			const hasAllTokens = givenPartnerTokenIds.every((tokenId) => tokenIds.includes(tokenId));

			expect(address).to.equal(partnerNFT.target);
			expect(hasAllTokens).to.equal(true);
		});

		it("Can Send received Tokens", async function () {
			const { owner, otherAccount, businessToken, loyaltyToken, loyaltyService } = await loadFixture(deployContractsFixture);
			const { partnerNFTService } = await loadFixture(deployPartnerNFTFixture);
			const { mockNFT: partnerNFT, mockNFTOwner: partnerNFTOwner } = await loadFixture(deployMockNFTContractFixture);

			await businessToken.safeMint(owner.address, stringToBytes32("ImageId"), [stringToBytes32("A Shop"), stringToBytes32("Restaurant")]);

			await partnerNFT.connect(partnerNFTOwner).setApprovalForAll(partnerNFTService, true);
			const partnerNFTTotalSupply = await partnerNFT.totalSupply();
			const allTokens = [];
			let i = 0;
			while (i < partnerNFTTotalSupply) {
				allTokens.push(i);
				i++;
			}

			await partnerNFTService.connect(partnerNFTOwner).bulkReceive(partnerNFT, allTokens, 0, businessToken);

			const partnerNFTInitialBalance = await partnerNFT.balanceOf(otherAccount);

			i = 0;
			while (i < partnerNFTTotalSupply) {
				await partnerNFTService.transferPartnerNFT(0, businessToken, partnerNFT, otherAccount, false);
				i++;
			}

			const partnerNFTBalance = await partnerNFT.balanceOf(otherAccount);

			expect(0).to.equal(partnerNFTInitialBalance);
			expect(partnerNFTTotalSupply).to.equal(partnerNFTBalance);
		});
	});
});
