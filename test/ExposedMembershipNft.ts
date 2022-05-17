import { ethers } from "hardhat";
import { BigNumber, Contract, Signer } from "ethers";
import chai from "chai";
import { solidity } from "ethereum-waffle";
import { getAddress } from "@ethersproject/address";
import { ExposedMembershipNft } from "../typechain/ExposedMembershipNft";
import { ExposedMembershipNftFactory } from "../typechain/ExposedMembershipNftFactory";

chai.use(solidity);

const { expect } = chai;

const INITIAL_URI = "https://token-cdn-domain/";
const NAME = "ValorizeNFT";
const SYMBOL = "VALOR";
const START_SEAL = 50;
const START_PLANKTON = 200;
const REMAINING_WHALE_TOKEN_IDS = [3, 18, 50, 0, 0];
const REMAINING_SEAL_TOKEN_IDS = [53, 68, 125, 200, 0];
const REMAINING_PLANKTON_TOKEN_IDS = [203, 223, 375, 1300, 3000];

describe("ExposedMembershipNft", () => {
  let membershipNft: ExposedMembershipNft,
    deployer: Signer,
    admin1: Signer,
    admin2: Signer,
    vault: Signer,
    addresses: Signer[];

  const setupMembershipNft = async () => {
    [deployer, admin1, admin2, vault, ...addresses] = await ethers.getSigners();
    membershipNft = await new ExposedMembershipNftFactory(deployer).deploy(NAME, SYMBOL,
      INITIAL_URI, START_SEAL, START_PLANKTON, REMAINING_WHALE_TOKEN_IDS, REMAINING_SEAL_TOKEN_IDS, REMAINING_PLANKTON_TOKEN_IDS,
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
      const whaleMyceliaId = await (await membershipNft.RarityTraitsByKey("Whale")).Mycelia;
      const recipientAddress = await addresses[0].getAddress();
      const data = '0x12345678';
      await membershipNft.whaleMint(recipientAddress, whaleMyceliaId, data);
      const recipientBalanceAfterMint = await membershipNft.balanceOf(recipientAddress);
      expect(recipientBalanceAfterMint).to.equal(1);
    });
    
    it("mints a diamond NFT using sealMint", async () => {
      const sealDiamondId = await (await membershipNft.RarityTraitsByKey("Seal")).Diamond;
      const recipientAddress = await addresses[0].getAddress();
      const data = '0x12345678';
      await membershipNft.sealMint(recipientAddress, sealDiamondId, data);
      const recipientBalanceAfterMint = await membershipNft.balanceOf(recipientAddress);
      expect(recipientBalanceAfterMint).to.equal(1);
    });

    it("mints a silver NFT using planktonMint", async () => {
      const planktonSilverId = await (await membershipNft.RarityTraitsByKey("Plankton")).Silver;
      const recipientAddress = await addresses[0].getAddress();
      const data = '0x12345678';
      await membershipNft.planktonMint(recipientAddress, planktonSilverId, data);
      const recipientBalanceAfterMint = await membershipNft.balanceOf(recipientAddress);
      expect(recipientBalanceAfterMint).to.equal(1);
    });

    it("reverts the minting of NFTs using whaleMint when tokenIds 1 to 50 are not available", async () => {
      const planktonSilverId = await (await membershipNft.RarityTraitsByKey("Plankton")).Silver;
      const recipientAddress = await addresses[0].getAddress();
      const data = '0x12345678';
      
      await expect(membershipNft.whaleMint(recipientAddress, planktonSilverId, data)
      ).to.be.revertedWith(
        "the whale NFTs are sold out");
    });

    it("reverts the minting of NFTs using sealMint when tokenIds 51 to 200 are not available", async () => {
      const planktonSilverId = await (await membershipNft.RarityTraitsByKey("Plankton")).Silver;
      const recipientAddress = await addresses[0].getAddress();
      const data = '0x12345678';
      
      await expect(membershipNft.sealMint(recipientAddress, planktonSilverId, data))
      .to.be.revertedWith(
        "the seal NFTs are sold out");
    });

    it("reverts the minting of NFTs using planktonMint when tokenIds 201 to 3000 are not available", async () => {
      const whaleDiamondId = await (await membershipNft.RarityTraitsByKey("Whale")).Diamond;
      const recipientAddress = await addresses[0].getAddress();
      const data = '0x12345678';
      await expect(membershipNft.planktonMint(recipientAddress, whaleDiamondId, data)
      ).to.be.revertedWith(
      "the plankton NFTs are sold out");
    });
  });

  describe("Setting up an allowlist and let the chosen address make a mint of choice", async () => {
    beforeEach(setupMembershipNft)

    it("sets allowlisted addresses to only mint one NFT", async () => {
      const whaleAddresses = [await addresses[0].getAddress(), await addresses[1].getAddress()];
      const sealAddresses = [await addresses[2].getAddress(), await addresses[3].getAddress()];
      const planktonAddresses = [await addresses[4].getAddress(), await addresses[5].getAddress()];
      await membershipNft.setAllowLists(whaleAddresses, sealAddresses, planktonAddresses);
      expect(await membershipNft.AllowList(planktonAddresses[0])).to.equal(true);
    });

    it("sets allowlisted addresses to NFT choice", async () => {
      const whaleAddresses = [await addresses[0].getAddress(), await addresses[1].getAddress()];
      const sealAddresses = [await addresses[2].getAddress(), await addresses[3].getAddress()];
      const planktonAddresses = [await addresses[4].getAddress(), await addresses[5].getAddress()];
      await membershipNft.setAllowLists(whaleAddresses, sealAddresses, planktonAddresses);
      expect(await membershipNft.ChoiceList(sealAddresses[0])).to.equal(2);
    });

    it("sets the allowlist while inactive and allows minting while the allow list is active", async () => {
      const whaleAddresses = [await addresses[0].getAddress(), await addresses[1].getAddress()];
      const sealAddresses = [await addresses[2].getAddress(), await addresses[3].getAddress()];
      const planktonAddresses = [await addresses[4].getAddress(), await addresses[5].getAddress()];
      await membershipNft.setAllowLists(whaleAddresses, sealAddresses, planktonAddresses);
      await membershipNft.connect(deployer).setIsAllowListActive(true);
      await membershipNft.connect(addresses[0]).allowListMint({value: ethers.utils.parseEther("1.0")});
      const recipientBalanceAfterMint = await membershipNft.balanceOf(whaleAddresses[0]);
      expect(recipientBalanceAfterMint).to.equal(1);
    });

    it("does not mint an NFT when the whitelisted address does not pay the correct amount", async () => {
      const whaleAddresses = [await addresses[0].getAddress(), await addresses[1].getAddress()];
      const sealAddresses = [await addresses[2].getAddress(), await addresses[3].getAddress()];
      const planktonAddresses = [await addresses[4].getAddress(), await addresses[5].getAddress()];
      await membershipNft.setAllowLists(whaleAddresses, sealAddresses, planktonAddresses);
      await membershipNft.connect(deployer).setIsAllowListActive(true);
      await expect(membershipNft.connect(addresses[0]).allowListMint({value: ethers.utils.parseEther("0.2")})
      ).to.be.revertedWith("Ether value sent is not correct");
    });
  });

  describe("setting the token URIs", async () => {
    beforeEach(setupMembershipNft)

    it("sets the token URI", async() => {
      const whaleMyceliaId = await (await membershipNft.RarityTraitsByKey("Whale")).Mycelia;
      const recipientAddress = await addresses[0].getAddress();
      const data = '0x12345678';
      await membershipNft.whaleMint(recipientAddress, whaleMyceliaId, data);
      const findTokenURI = await membershipNft.tokenURI(whaleMyceliaId);
      expect(findTokenURI).to.equal("https://token-cdn-domain/3")
    });
  });
})