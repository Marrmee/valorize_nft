import { ethers } from "hardhat";
import { BigNumber, Contract, Signer } from "ethers";
import chai from "chai";
import { solidity } from "ethereum-waffle";
import { getAddress } from "@ethersproject/address";
import { ProductNft } from "../typechain/ProductNft";
import { ProductNftFactory } from "../typechain/ProductNftFactory";

chai.use(solidity);

const { expect } = chai;

const NAME = "ValorizeNFT";
const SYMBOL = "VALOR";
const BASE_URI = "https://token-cdn-domain/";
const START_RARER = 10;
const START_RARE = 1010;
const RAREST_TOKENS_LEFT = 10;
const RARE_TOKENS_LEFT = 1000;
const REMAINING_RARER_TOKEN_IDS = [110, 360, 1010];//amounts are 100, 250, 650


describe("ProductNft", () => {
  let productNft: ProductNft,
    deployer: Signer,
    admin1: Signer,
    admin2: Signer,
    vault: Signer,
    addresses: Signer[];

  const setupProductNft = async () => {
    [deployer, admin1, admin2, vault, ...addresses] = await ethers.getSigners();
    productNft = await new ProductNftFactory(deployer).deploy(
      BASE_URI, START_RARER, START_RARE,
    );
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

    it("mints a rarest NFT", async () => {
      const overridesRarest = {value: ethers.utils.parseEther("1.5")}
      const leftBeforeMint = await productNft.rarestTokensLeft();
      await productNft.rarestMint(overridesRarest);
      const leftAfterMint = await productNft.rarestTokensLeft();
      expect(leftBeforeMint).to.equal(leftAfterMint.add(1));
    });

    it("mints a rarer NFT", async () => {
      const overridesRarer = {value: ethers.utils.parseEther("0.55")}
      const tokenIdBeforeMint = await productNft.startRarerTokenId();
      await productNft.rarerOrderMint(overridesRarer);
      const tokenIdAfterMint = await productNft.startRarerTokenId();
      expect(tokenIdAfterMint).to.equal(tokenIdBeforeMint+1);
    });

    it("mints a rare NFT", async () => {
      const overridesRare = {value: ethers.utils.parseEther("0.2")}
      const leftBeforeMint = await productNft.rareTokensLeft();
      await productNft.rareMint(overridesRare);
      const leftAfterMint = await productNft.rareTokensLeft();
      expect(leftBeforeMint).to.equal(leftAfterMint.add(1));
    });
  });

  
  describe("setting the token URIs", async () => {
    beforeEach(setupProductNft)

    it("sets the token URI for rarest mint", async() => {
      const overridesRarest = {value: ethers.utils.parseEther("1.5")}
      await productNft.rarestMint(overridesRarest);
      const tokenId = RAREST_TOKENS_LEFT;
      const findTokenURI = await productNft.tokenURI(tokenId);
      expect(findTokenURI).to.equal("https://token-cdn-domain/10");
    });
  });

  describe("get rarity by tokenId", async () => {
    beforeEach(setupProductNft)

    it(" emits the rarity when tokenId is given", async() => {
      const getRarity = await productNft.getRarityByTokenId(5);
      expect(getRarity).to.emit(productNft, "returnRarityByTokenId").withArgs(5, "Mycelia");
    });
  });

  // describe("get royalty info by tokenId and sale price", async () => {
  //   beforeEach(setupProductNft)

  //   it("returns the royalty info to the artist", async() => {
  //     const getRarity = await productNft.getRarityByTokenId(5);
  //     expect(getRarity).to.emit(productNft, "returnRarityByTokenId").withArgs(5, "Mycelia");
  //   });
  // });
});