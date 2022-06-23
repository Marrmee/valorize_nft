import { ethers } from "hardhat";
import { BigNumber, Contract, Signer } from "ethers";
import chai from "chai";
import { solidity } from "ethereum-waffle";
import { getAddress } from "@ethersproject/address";
import { ProductNft } from "../typechain/ProductNft";
import { ProductNftFactory } from "../typechain/ProductNftFactory";
import { string } from "hardhat/internal/core/params/argumentTypes";

chai.use(solidity);

const { expect } = chai;

const BASE_URI = "https://token-cdn-domain/";
const START_RARER = 12;
const START_RARE = 1012;

describe.only("ProductNft", () => {
  let productNft: ProductNft,
    deployer: Signer,
    admin1: Signer,
    admin2: Signer,
    vault: Signer,
    addresses: Signer[];

  const setupProductNft = async () => {
    [deployer, admin1, admin2, vault, ...addresses] = await ethers.getSigners();
    productNft = await new ProductNftFactory(deployer).deploy(BASE_URI, START_RARER, START_RARE,);
    await productNft.deployed();
  };

  describe("Deployment", async () => {
    beforeEach(setupProductNft)

    it("should deploy", async () => {
      expect(productNft).to.be.ok;
    });
  })

  describe("Minting random plankton, seal and whale NFTs", async () => {
    beforeEach(setupProductNft)

    it("batch mints a rarest NFT", async () => {
      const overridesRarest = {value: ethers.utils.parseEther("7.5")}
      const tokenCountBeforeMint = await productNft.rarestTokenIds();
      const mintAmount = 5;
      await productNft.rarestBatchMint(mintAmount, overridesRarest);
      const tokenCountAfterMint = await productNft.rarestTokenIds();
      expect(tokenCountAfterMint).to.equal(tokenCountBeforeMint.add(mintAmount));
    });

    it("batch mints too many rarest NFTs", async () => {
      const overridesRarest = {value: ethers.utils.parseEther("20")}
      const mintAmount = 13;
      await expect(productNft.rarestBatchMint(mintAmount, overridesRarest)
      ).to.be.revertedWith("Mycelia NFTs are sold out");
    });

    it("reverts rarest batch mint when not enough Ether is sent", async () => {
      const overridesRarest = {value: ethers.utils.parseEther("5")}
      const mintAmount = 9;
      await expect(productNft.rarestBatchMint(mintAmount, overridesRarest)
      ).to.be.revertedWith("Ether value sent is not correct");
    });

    it("reverts rarest batch mint when the chosen amount is zero", async () => {
      const overridesRarest = {value: ethers.utils.parseEther("5")}
      const mintAmount = 0;
      await expect(productNft.rarestBatchMint(mintAmount, overridesRarest)
      ).to.be.revertedWith("You need to mint atleast one NFT");
    });

    it("batch mints a rarer NFT", async () => {
      const overridesRarer = {value: ethers.utils.parseEther("6")}
      const tokenIdBeforeMint = await productNft.rarerTokenIds();
      const mintAmount = 5;
      await productNft.rarerBatchMint(mintAmount, overridesRarer);
      const tokenIdAfterMint = await productNft.rarerTokenIds();
      expect(tokenIdAfterMint).to.equal(tokenIdBeforeMint.add(5));
    });

    // it("batch mints too many rarest NFTs", async () => {
    //   const overridesRarer = {value: ethers.utils.parseEther("10000")}
    //   const mintAmount = 1001;
    //   await expect(productNft.rarerBatchMint(mintAmount, overridesRarer)
    //   ).to.be.revertedWith("Diamond NFTs are sold out");
    // });

    it("reverts rarer batch mint when not enough Ether is sent", async () => {
      const overridesRarer = {value: ethers.utils.parseEther("1")}
      const mintAmount = 4;
      await expect(productNft.rarerBatchMint(mintAmount, overridesRarer)
      ).to.be.revertedWith("Ether value sent is not correct");
    });

    it("reverts rarer batch mint when the chosen amount is zero", async () => {
      const overridesRarest = {value: ethers.utils.parseEther("5")}
      const mintAmount = 0;
      await expect(productNft.rarerBatchMint(mintAmount, overridesRarest)
      ).to.be.revertedWith("You need to mint atleast one NFT");
    });

    it("batch mints a rare NFT", async () => {
      const overridesRare = {value: ethers.utils.parseEther("5")}
      const tokenCountBeforeMint = await productNft.rareTokenIds();
      const mintAmount = 10;
      await productNft.rareBatchMint(mintAmount, overridesRare);
      const tokenCountAfterMint = await productNft.rareTokenIds();
      expect(tokenCountAfterMint).to.equal(tokenCountBeforeMint.add(10));
    });

    it("reverts rare batch mint when not enough Ether is sent", async () => {
      const overridesRarer = {value: ethers.utils.parseEther("1")}
      const mintAmount = 6;
      await expect(productNft.rareBatchMint(mintAmount, overridesRarer)
      ).to.be.revertedWith("Ether value sent is not correct");
    });

    it("reverts rare batch mint when the chosen amount is zero", async () => {
      const overridesRarest = {value: ethers.utils.parseEther("5")}
      const mintAmount = 0;
      await expect(productNft.rareBatchMint(mintAmount, overridesRarest)
      ).to.be.revertedWith("You need to mint atleast one NFT");
    });
  });
  
  describe("setting the token URIs", async () => {
    beforeEach(setupProductNft)

    it("sets the token URI for rarest mint", async() => {
      const overridesRarest = {value: ethers.utils.parseEther("1.5")}
      const amount = 1;
      await productNft.rarestBatchMint(amount, overridesRarest);
      const tokenId = await productNft.rarestTokenIds();
      const findTokenURI = await productNft._URI(tokenId);
      expect(findTokenURI).to.equal("https://token-cdn-domain/" + tokenId + ".json");
    });
  });

  // describe("get rarity by tokenId", async () => {
  //   beforeEach(setupProductNft)

  //   it("emits the rarity when tokenId is given", async() => {
  //     const tokenId = 1;
  //     const getTokenInfo = await productNft.emitTokenInfo(tokenId);
  //     expect(getTokenInfo).to.emit(productNft, "returnTokenInfo").withArgs(
  //       tokenId, "Mycelia"
  //     );
  //   });

  //   it("returns the rarity when tokenId is given", async() => {
  //     const tokenId = 1;
  //     const getTokenInfo = await productNft.emitTokenInfo(tokenId);
  //     expect(getTokenInfo).to.emit(productNft, "returnTokenInfo").withArgs(
  //       tokenId, "Mycelia"
  //     );
  //   });
  // });

  // describe("get royalty info by tokenId and sale price", async () => {
  //   beforeEach(setupProductNft)

  //   it("returns the royalty info to the artist", async() => {
  //     const getRarity = await productNft.getRarityByTokenId(5);
  //     expect(getRarity).to.emit(productNft, "returnRarityByTokenId").withArgs(5, "Mycelia");
  //   });
  // });
});