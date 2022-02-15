import { ethers } from "hardhat";
import { BigNumber, Contract, Signer } from "ethers";
import chai from "chai";
import { solidity } from "ethereum-waffle";
import { getAddress } from "@ethersproject/address";
import { NonFungibleToken } from "./../typechain/NonFungibleToken.d";
import { NonFungibleTokenFactory } from "./../typechain/NonFungibleTokenFactory";

chai.use(solidity);

const { expect } = chai;

const INITIAL_URI = 'https://token-cdn-domain/{id}.json';


describe("NonFungibleToken", () => {
  let nonFungibleToken: NonFungibleToken,
    deployer: Signer,
    admin1: Signer,
    admin2: Signer,
    vault: Signer,
    addresses: Signer[];

  const setupNonFungibleToken = async () => {
    [deployer, admin1, admin2, vault, ...addresses] = await ethers.getSigners();
    nonFungibleToken = await new NonFungibleTokenFactory(deployer).deploy(
      INITIAL_URI,
    );
    await nonFungibleToken.deployed();
  };

/**describe('internal functions', function () {
  const tokenId = new BN(1990);
  const mintAmount = new BN(9001);
  const burnAmount = new BN(3000);
  const tokenBatchIds = [new BN(2000), new BN(2010), new BN(2020)];
  const mintAmounts = [new BN(5000), new BN(10000), new BN(42195)];
  const burnAmounts = [new BN(5000), new BN(9001), new BN(195)];
  const data = '0x12345678';
}*/

  describe("Deployment", async () => {
    beforeEach(setupNonFungibleToken)

    it("should deploy", async () => {
      expect(nonFungibleToken).to.be.ok;
    });
  })

  describe("Minting shrimp, seal and whale NFTs", async () => {
    beforeEach(setupNonFungibleToken)

    it("returns the new whale token Ids", async () => {

    })

    it("mints one whale NFT", async () => {
      const data = '0x12345678';
      const mintAmounts = [0, 0, 0];
      const recipientAddress = await addresses[0].getAddress();
      const nftMint = await nonFungibleToken.whaleBatchMint(recipientAddress, mintAmounts, data);
      const newTokenIds = [1, 2, 3]; //how to call an array?
      const recipientBalance = await nonFungibleToken.balanceOf(recipientAddress, newTokenIds); //address, tokenId
      expect(recipientBalance).to.equal(mintAmounts);
    });

    /**it("mints one whale NFT", async () => {
    const data = '0x12345678';
    const mintAmounts = [0, 0, 0];
    const recipientAddress = await addresses[0].getAddress();
    const nftMint = await nonFungibleToken.whaleBatchMint(recipientAddress, mintAmounts, data);
    const newTokenIds = [1, 8, 3]; //how to call an array?
    const recipientBalance = await nonFungibleToken.balanceOf(recipientAddress, newTokenIds); //address, tokenId
    expect(recipientBalance).to.equal(mintAmounts);
  });
  })
})
