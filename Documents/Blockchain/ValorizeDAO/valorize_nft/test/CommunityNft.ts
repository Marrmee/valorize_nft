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


describe("CommunityNft", () => {
  let communityNft: CommunityNft,
    deployer: Signer,
    admin1: Signer,
    admin2: Signer,
    vault: Signer,
    addresses: Signer[];

  const setupCommunityNft = async () => {
    [deployer, admin1, admin2, vault, ...addresses] = await ethers.getSigners();
    communityNft = await new CommunityNftFactory(deployer).deploy(
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

  describe("Minting plankton, seal and whale NFTs", async () => {
    beforeEach(setupCommunityNft)

    it("mints one whale NFT to a given address", async () => {
      const data = '0x12345678';
      const mintAmounts = [1];
      const recipientAddress = await addresses[0].getAddress();
      await communityNft.whaleBatchMint(recipientAddress, mintAmounts, data);
      const newTokenIds = [1];
      const recipientBalance = await communityNft.balanceOf(recipientAddress, newTokenIds);
      expect(recipientBalance).to.equal(newTokenIds);
    });

    it("mints too many whale NFTs", async () => {
      const data = '0x12345678';
      const mintAmounts = [51];
      const recipientAddress = await addresses[0].getAddress();
      await expect(communityNft.whaleBatchMint(recipientAddress, mintAmounts, data)).to.be.revertedWith("Diamond, Platinum and Obsidian NFTs are sold out");
    })

    it("mints zero whale NFTs", async () => {
      const data = '0x12345678';
      const mintAmounts = [0];
      const recipientAddress = await addresses[0].getAddress();
      await expect(communityNft.whaleBatchMint(recipientAddress, mintAmounts, data)).to.be.revertedWith("You need to mint atleast one NFT");
    })

    it("mints one seal NFT to a given address", async () => {
      const data = '0x12345678';
      const mintAmounts = [1];
      const recipientAddress = await addresses[0].getAddress();
      await communityNft.sealBatchMint(recipientAddress, mintAmounts, data);
      const newTokenIds = [1];
      const recipientBalance = await communityNft.balanceOf(recipientAddress, newTokenIds);
      expect(recipientBalance).to.equal(newTokenIds);
    });

    it("mints too many seal NFTs", async () => {
      const data = '0x12345678';
      const mintAmounts = [301];
      const recipientAddress = await addresses[0].getAddress();
      await expect(communityNft.sealBatchMint(recipientAddress, mintAmounts, data)).to.be.revertedWith("Gold NFTS are sold out");
    })

    it("mints zero seal NFTs", async () => {
      const data = '0x12345678';
      const mintAmounts = [0];
      const recipientAddress = await addresses[0].getAddress();
      await expect(communityNft.sealBatchMint(recipientAddress, mintAmounts, data)).to.be.revertedWith("You need to mint atleast one NFT");
    })    
  
    it("mints one whale NFT to a given address", async () => {
      const data = '0x12345678';
      const mintAmounts = [1];
      const recipientAddress = await addresses[0].getAddress();
      await communityNft.planktonBatchMint(recipientAddress, mintAmounts, data);
      const newTokenIds = [1];
      const recipientBalance = await communityNft.balanceOf(recipientAddress, newTokenIds);
      expect(recipientBalance).to.equal(newTokenIds);
    });

    it("mints too many plankton NFTs", async () => {
      const data = '0x12345678';
      const mintAmounts = [1001];
      const recipientAddress = await addresses[0].getAddress();
      await expect(communityNft.planktonBatchMint(recipientAddress, mintAmounts, data)).to.be.revertedWith("Silver NFTs are sold out");
    })

    it("mints zero plankton NFTs", async () => {
      const data = '0x12345678';
      const mintAmounts = [0];
      const recipientAddress = await addresses[0].getAddress();
      await expect(communityNft.planktonBatchMint(recipientAddress, mintAmounts, data)).to.be.revertedWith("You need to mint atleast one NFT");
    })
  });
})