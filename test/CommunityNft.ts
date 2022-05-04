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
      const overridesWhale = {value: ethers.utils.parseEther("1.0")}
      const leftBeforeMint = await communityNft.whaleTokensLeft();
      await communityNft.getRandomWhaleNFT(overridesWhale);
      const leftAfterMint = await communityNft.whaleTokensLeft();
      expect(leftBeforeMint).to.equal(leftAfterMint.add(1));
    });

    it("mints a random seal NFT", async () => {
      const overridesSeal = {value: ethers.utils.parseEther("0.2")}
      const leftBeforeMint = await communityNft.sealTokensLeft();
      await communityNft.getRandomSealNFT(overridesSeal);
      const leftAfterMint = await communityNft.sealTokensLeft();
      expect(leftBeforeMint).to.equal(leftAfterMint.add(1));
    });

    it("mints a random plankton NFT", async () => {
      const overridesPlankton = {value: ethers.utils.parseEther("0.1")}
      const leftBeforeMint = await communityNft.planktonTokensLeft();
      await communityNft.getRandomPlanktonNFT(overridesPlankton);
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

    it("sets the whitelist while inactive and allows whitelisted addresses to mint Whale NFTs while active", async () => {
      const addressesForWhitelist = [await addresses[0].getAddress(), await addresses[1].getAddress()];
      const tokensToBeMintedPerAddress = 1;
      await communityNft.setWhaleAllowList(addressesForWhitelist, tokensToBeMintedPerAddress);
      const whiteListed = await addresses[0].getAddress();
      await communityNft.connect(deployer).setIsWhaleAllowListActive(true);
      const overridesWhale = {value: ethers.utils.parseEther("1.0")}
      await communityNft.connect(addresses[0]).whaleMintAllowList(1, overridesWhale);
      const recipientBalanceAfterMint = await communityNft.balanceOf(whiteListed);
      expect(recipientBalanceAfterMint).to.equal(1);
    });

    it("sets the whitelist while inactive and allows whitelisted addresses to mint Seal NFTs while active", async () => {
      const addressesForWhitelist = [await addresses[0].getAddress(), await addresses[1].getAddress()];
      const tokensToBeMintedPerAddress = 1;
      await communityNft.setSealAllowList(addressesForWhitelist, tokensToBeMintedPerAddress);
      const whiteListed = await addresses[0].getAddress();
      await communityNft.connect(deployer).setIsSealAllowListActive(true);
      const overridesSeal = {value: ethers.utils.parseEther("0.2")}
      await communityNft.connect(addresses[0]).sealMintAllowList(1, overridesSeal);
      const recipientBalanceAfterMint = await communityNft.balanceOf(whiteListed);
      expect(recipientBalanceAfterMint).to.equal(1);
    });

    it("sets the whitelist while inactive and allows whitelisted addresses to mint Plankton NFTs while active", async () => {
      const addressesForWhitelist = [await addresses[0].getAddress(), await addresses[1].getAddress()];
      const tokensToBeMintedPerAddress = 1;
      await communityNft.setPlanktonAllowList(addressesForWhitelist, tokensToBeMintedPerAddress);
      const whiteListed = await addresses[0].getAddress();
      await communityNft.connect(deployer).setIsPlanktonAllowListActive(true);
      const overridesSeal = {value: ethers.utils.parseEther("0.1")}
      await communityNft.connect(addresses[0]).planktonMintAllowList(1, overridesSeal);
      const recipientBalanceAfterMint = await communityNft.balanceOf(whiteListed);
      expect(recipientBalanceAfterMint).to.equal(1);
    });
  });
  describe("updating the URI after mint", async () => {
    beforeEach(setupCommunityNft)

    it("toggels reveal")

  });
})