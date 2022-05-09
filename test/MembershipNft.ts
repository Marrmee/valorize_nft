import { ethers } from "hardhat";
import { BigNumber, Contract, Signer } from "ethers";
import chai from "chai";
import { solidity } from "ethereum-waffle";
import { getAddress } from "@ethersproject/address";
import { MembershipNft } from "../typechain/MembershipNft";
import { MembershipNftFactory } from "./../typechain/MembershipNftFactory";

chai.use(solidity);

const { expect } = chai;

const INITIAL_URI = 'https://token-cdn-domain/';
const NAME = "ValorizeNFT";
const SYMBOL = "VALOR";

describe("MembershipNft", () => {
  let membershipNft: MembershipNft,
    deployer: Signer,
    admin1: Signer,
    admin2: Signer,
    vault: Signer,
    addresses: Signer[];

  const setupMembershipNft = async () => {
    [deployer, admin1, admin2, vault, ...addresses] = await ethers.getSigners();
    membershipNft = await new MembershipNftFactory(deployer).deploy(NAME, SYMBOL,
      INITIAL_URI,
    );
    await membershipNft.deployed();
  };

  describe("Deployment", async () => {
    beforeEach(setupMembershipNft)

    it("should deploy", async () => {
      expect(membershipNft).to.be.ok;
    });
  })

  describe("Minting random plankton, seal and whale NFTs", async () => {
    beforeEach(setupMembershipNft)

    it("mints a random whale NFT", async () => {
      const overridesWhale = {value: ethers.utils.parseEther("1.0")}
      const leftBeforeMint = await membershipNft.whaleTokensLeft();
      await membershipNft.mintRandomWhaleNFT(overridesWhale);
      const leftAfterMint = await membershipNft.whaleTokensLeft();
      expect(leftBeforeMint).to.equal(leftAfterMint.add(1));
    });

    it("mints a random seal NFT", async () => {
      const overridesSeal = {value: ethers.utils.parseEther("0.2")}
      const leftBeforeMint = await membershipNft.sealTokensLeft();
      await membershipNft.mintRandomSealNFT(overridesSeal);
      const leftAfterMint = await membershipNft.sealTokensLeft();
      expect(leftBeforeMint).to.equal(leftAfterMint.add(1));
    });

    it("mints a random plankton NFT", async () => {
      const overridesPlankton = {value: ethers.utils.parseEther("0.1")}
      const leftBeforeMint = await membershipNft.planktonTokensLeft();
      await membershipNft.mintRandomPlanktonNFT(overridesPlankton);
      const leftAfterMint = await membershipNft.planktonTokensLeft();
      expect(leftBeforeMint).to.equal(leftAfterMint.add(1));
    });
  });

  describe("Minting non-random plankton, seal and whale NFTs", async () => {
    beforeEach(setupMembershipNft)

    it("mints a mycelia NFT using whaleMint", async () => {
      const whaleMyceliaId = await membershipNft.remainingWhaleMyceliaId();
      const recipientAddress = await addresses[0].getAddress();
      const data = '0x12345678';
      await membershipNft.whaleMint(recipientAddress, whaleMyceliaId, data);
      const recipientBalanceAfterMint = await membershipNft.balanceOf(recipientAddress);
      expect(recipientBalanceAfterMint).to.equal(1);
    });

    it("mints a diamond NFT using sealMint", async () => {
      const sealDiamondId = await membershipNft.remainingSealDiamondId();
      const recipientAddress = await addresses[0].getAddress();
      const data = '0x12345678';
      await membershipNft.sealMint(recipientAddress, sealDiamondId, data);
      const recipientBalanceAfterMint = await membershipNft.balanceOf(recipientAddress);
      expect(recipientBalanceAfterMint).to.equal(1);
    });

    it("mints a silver NFT using planktonMint", async () => {
      const planktonSilverId = await membershipNft.remainingPlanktonSilverId();
      const recipientAddress = await addresses[0].getAddress();
      const data = '0x12345678';
      await membershipNft.planktonMint(recipientAddress, planktonSilverId, data);
      const recipientBalanceAfterMint = await membershipNft.balanceOf(recipientAddress);
      expect(recipientBalanceAfterMint).to.equal(1);
    });

    it("reverts the minting of NFTs using whaleMint when tokenIds 1 to 50 are not available", async () => {
      const planktonSilverId = await membershipNft.remainingPlanktonSilverId();
      const recipientAddress = await addresses[0].getAddress();
      const data = '0x12345678';
      
      await expect(membershipNft.whaleMint(recipientAddress, planktonSilverId, data)
      ).to.be.revertedWith(
        "the whale NFTs are sold out");
    });

    it("reverts the minting of NFTs using sealMint when tokenIds 51 to 200 are not available", async () => {
      const planktonSilverId = await membershipNft.remainingPlanktonSilverId();
      const recipientAddress = await addresses[0].getAddress();
      const data = '0x12345678';
      
      await expect(membershipNft.sealMint(recipientAddress, planktonSilverId, data))
      .to.be.revertedWith(
        "the seal NFTs are sold out");
    });

    it("reverts the minting of NFTs using planktonMint when tokenIds 201 to 3000 are not available", async () => {
      const planktonSilverId = await membershipNft.whaleMyceliaId();
      const recipientAddress = await addresses[0].getAddress();
      const data = '0x12345678';
      await expect(membershipNft.planktonMint(recipientAddress, planktonSilverId, data)
      ).to.be.revertedWith(
      "the plankton NFTs are sold out");
    });
  });

  describe("Setting up a whitelist and let a whitelisted address make a mint of choice", async () => {
    beforeEach(setupMembershipNft)

    it("sets the whitelist while inactive and allows whitelisted addresses to mint Whale NFTs while active", async () => {
      const addressesForWhitelist = [await addresses[0].getAddress(), await addresses[1].getAddress()];
      const tokensToBeMintedPerAddress = 1;
      await membershipNft.setWhaleAllowList(addressesForWhitelist, tokensToBeMintedPerAddress);
      const whiteListed = await addresses[0].getAddress();
      await membershipNft.connect(deployer).setIsWhaleAllowListActive(true);
      const overridesWhale = {value: ethers.utils.parseEther("1.0")}
      await membershipNft.connect(addresses[0]).whaleMintAllowList(1, overridesWhale);
      const recipientBalanceAfterMint = await membershipNft.balanceOf(whiteListed);
      expect(recipientBalanceAfterMint).to.equal(1);
    });

    it("sets the whitelist while inactive and allows whitelisted addresses to mint Seal NFTs while active", async () => {
      const addressesForWhitelist = [await addresses[0].getAddress(), await addresses[1].getAddress()];
      const tokensToBeMintedPerAddress = 1;
      await membershipNft.setSealAllowList(addressesForWhitelist, tokensToBeMintedPerAddress);
      const whiteListed = await addresses[0].getAddress();
      await membershipNft.connect(deployer).setIsSealAllowListActive(true);
      const overridesSeal = {value: ethers.utils.parseEther("0.2")}
      await membershipNft.connect(addresses[0]).sealMintAllowList(1, overridesSeal);
      const recipientBalanceAfterMint = await membershipNft.balanceOf(whiteListed);
      expect(recipientBalanceAfterMint).to.equal(1);
    });

    it("sets the whitelist while inactive and allows whitelisted addresses to mint Plankton NFTs while active", async () => {
      const addressesForWhitelist = [await addresses[0].getAddress(), await addresses[1].getAddress()];
      const tokensToBeMintedPerAddress = 1;
      await membershipNft.setPlanktonAllowList(addressesForWhitelist, tokensToBeMintedPerAddress);
      const whiteListed = await addresses[0].getAddress();
      await membershipNft.connect(deployer).setIsPlanktonAllowListActive(true);
      const overridesSeal = {value: ethers.utils.parseEther("0.1")}
      await membershipNft.connect(addresses[0]).planktonMintAllowList(1, overridesSeal);
      const recipientBalanceAfterMint = await membershipNft.balanceOf(whiteListed);
      expect(recipientBalanceAfterMint).to.equal(1);
    });
  });
  describe("setting the token URIs", async () => {
    beforeEach(setupMembershipNft)

    it("sets the token URI", async() =>{
      const INITIAL_URI = "https://token-cdn-domain/";
      await membershipNft._baseURI(INITIAL_URI);
      const tokenID = 3;
      const findTokenURI = await membershipNft.tokenURI(tokenID);
      expect(findTokenURI).to.equal("https://token-cdn-domain/3")
    })

  });
})