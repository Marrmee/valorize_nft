import { ethers } from "hardhat";
import { BigNumber, Contract, Signer } from "ethers";
import chai from "chai";
import { solidity } from "ethereum-waffle";
import { getAddress } from "@ethersproject/address";
import { CommunityNft } from "../typechain/CommunityNft";
import { CommunityNftFactory } from "./../typechain/CommunityNftFactory";

chai.use(solidity);

const { expect } = chai;

const INITIAL_URI = 'https://token-cdn-domain/{id}.json';
const NAME = "ValorizeNFT";
const SYMBOL = "VALOR";

describe("CommunityNft", () => {
  let communityNft: CommunityNft,
    deployer: Signer,
    admin1: Signer,
    admin2: Signer,
    vault: Signer,
    addresses: Signer[];

  const setupCommunityNft = async () => {
    [deployer, admin1, admin2, vault, ...addresses] = await ethers.getSigners();
    communityNft = await new CommunityNftFactory(deployer).deploy(NAME, SYMBOL,
      INITIAL_URI,
    );
    await communityNft.deployed();
  };

  describe("Deployment", async () => {
    beforeEach(setupCommunityNft)

    it("should deploy", async () => {
      expect(communityNft).to.be.ok;
    });
  })

  describe("Minting random plankton, seal and whale NFTs", async () => {
    beforeEach(setupCommunityNft)

    it("mints a random whale NFT", async () => {
      const leftBeforeMint = await communityNft.whaleTokensLeft();
      await communityNft.getRandomWhaleNFT();
      const leftAfterMint = await communityNft.whaleTokensLeft();
      expect(leftBeforeMint).to.equal(leftAfterMint.add(1));
    });

    it("mints a random seal NFT", async () => {
      const leftBeforeMint = await communityNft.sealTokensLeft();
      await communityNft.getRandomSealNFT();
      const leftAfterMint = await communityNft.sealTokensLeft();
      expect(leftBeforeMint).to.equal(leftAfterMint.add(1));
    });

    it("mints a random plankton NFT", async () => {
      const leftBeforeMint = await communityNft.planktonTokensLeft();
      await communityNft.getRandomPlanktonNFT();
      const leftAfterMint = await communityNft.planktonTokensLeft();
      expect(leftBeforeMint).to.equal(leftAfterMint.add(1));
    });
  });

  describe("Minting non-random plankton, seal and whale NFTs", async () => {
    beforeEach(setupCommunityNft)

    it("mints a mycelia NFT using whaleMint", async () => {
      const whaleMyceliaId = await communityNft.whaleMyceliaId();
      const recipientAddress = await addresses[0].getAddress();
      const data = '0x12345678';
      await communityNft.whaleMint(recipientAddress, whaleMyceliaId, data);
      const recipientBalanceAfterMint = await communityNft.balanceOf(recipientAddress);
      expect(recipientBalanceAfterMint).to.equal(1);
    });

    it("mints a diamond NFT using sealMint", async () => {
      const sealDiamondId = await communityNft.sealDiamondId();
      const recipientAddress = await addresses[0].getAddress();
      const data = '0x12345678';
      await communityNft.sealMint(recipientAddress, sealDiamondId, data);
      const recipientBalanceAfterMint = await communityNft.balanceOf(recipientAddress);
      expect(recipientBalanceAfterMint).to.equal(1);
    });

    it("mints a silver NFT using planktonMint", async () => {
      const planktonSilverId = await communityNft.planktonSilverId();
      const recipientAddress = await addresses[0].getAddress();
      const data = '0x12345678';
      await communityNft.planktonMint(recipientAddress, planktonSilverId, data);
      const recipientBalanceAfterMint = await communityNft.balanceOf(recipientAddress);
      expect(recipientBalanceAfterMint).to.equal(1);
    });

    it("reverts the minting of NFTs using whaleMint when tokenIds 1 to 50 are not available", async () => {
      const planktonSilverId = await communityNft.planktonSilverId();
      const recipientAddress = await addresses[0].getAddress();
      const data = '0x12345678';
      
      await expect(communityNft.whaleMint(recipientAddress, planktonSilverId, data)
      ).to.be.revertedWith(
        "the whale NFTs are sold out");
    });

    it("reverts the minting of NFTs using sealMint when tokenIds 51 to 200 are not available", async () => {
      const planktonSilverId = await communityNft.planktonSilverId();
      const recipientAddress = await addresses[0].getAddress();
      const data = '0x12345678';
      
      await expect(communityNft.sealMint(recipientAddress, planktonSilverId, data))
      .to.be.revertedWith(
        "the seal NFTs are sold out");
    });

    it("reverts the minting of NFTs using planktonMint when tokenIds 201 to 3000 are not available", async () => {
      const planktonSilverId = await communityNft.whaleMyceliaId();
      const recipientAddress = await addresses[0].getAddress();
      const data = '0x12345678';
      await expect(communityNft.planktonMint(recipientAddress, planktonSilverId, data)
      ).to.be.revertedWith(
      "the plankton NFTs are sold out");
    });
  });

describe("Setting up a whitelist and let a whitelisted address make a mint of choice", async () => {
  beforeEach(setupCommunityNft)

    it("sets the whale whitelist while it is inactive", async () => {
      const addressesForWhitelist = [await addresses[0].getAddress(), await addresses[1].getAddress()];
      const tokensToBeMintedPerAddress = 1;
      await communityNft.setWhaleAllowList(addressesForWhitelist, tokensToBeMintedPerAddress)
    });

    it("sets the whitelist while inactive and allows whitelisted addresses to mint while the active", async () => {
      const addressesForWhitelist = [await addresses[0].getAddress(), await addresses[1].getAddress()];
      const tokensToBeMintedPerAddress = 1;
      await communityNft.setWhaleAllowList(addressesForWhitelist, tokensToBeMintedPerAddress);

      await communityNft.connect(deployer).setIsWhaleAllowListActive(true);
      const numberOfTokensToMint = 1;

      await communityNft.connect(addresses[0]).whaleMintAllowList(numberOfTokensToMint);
    });
  });
})