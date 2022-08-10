//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
@title MembershipNft
@author Marco Huberts & Javier Gonzalez
@dev Implementation of a Membership Non Fungible Token using ERC721.
*/

contract MembershipNft is ERC721 {

    string public URI;

    uint256 public constant PRICE_PER_WHALE_TOKEN = 1.0 ether;
    uint256 public constant PRICE_PER_SEAL_TOKEN = 0.2 ether;
    uint256 public constant PRICE_PER_PLANKTON_TOKEN = 0.1 ether;

    uint256 public whaleTokensLeft;
    uint256 public sealTokensLeft;
    uint256 public planktonTokensLeft;
    
    uint256 public totalWhaleTokenAmount;
    uint256 public totalSealTokenAmount;
    uint256 public totalPlanktonTokenAmount;

    mapping(MintType => RemainingFunctionCalls) public RarityTraitsByKey;

    event returnRarityByTokenId(uint256 tokenId, string rarity);
      /**       
      amounts     
                Mycelia Obsidian Diamond Gold Silver Total
        whale     3       15      35      0     0    50
        seal      3       17      40     90     0    150 
        plankton  4       60     125     310   2301  2800
        total     10      90     200     400   2301  3000

      tokenIds
               Mycelia Obsidian Diamond Gold Silver
        whale     3       15      50      0      0   
        seal      53      70     110    200      0   
        plankton  204    264     389    699   3000
      */
    struct RemainingFunctionCalls {
      uint256 Mycelia;
      uint256 Obsidian;
      uint256 Diamond;
      uint256 Gold;
      uint256 Silver;
    }

    enum Rarity { Mycelia, Obsidian, Diamond, Gold, Silver }
    enum MintType { Whale, Seal, Plankton }

  constructor(
    string memory _URI,
    uint256[] memory _remainingWhaleFunctionCalls, //  [3, 12, 35, 0, 0] // [3, 6, 9, 0, 0] //[1, 2, 3, 0, 0]
    uint256[] memory _remainingSealFunctionCalls, //   [3, 18, 40, 90, 0] // [3, 6, 9, 12, 0] // [1, 2, 3, 4, 0]
    uint256[] memory _remainingPlanktonFunctionCalls //[4, 60, 125, 310, 2301] // [3, 6, 9, 12, 15] // [1, 2, 3, 4, 5]
  ) ERC721("MEMBERSHIP", "VMEMB") {
    URI = _URI;
    
    whaleTokensLeft = (_remainingWhaleFunctionCalls[0] + _remainingWhaleFunctionCalls[1] + _remainingWhaleFunctionCalls[2] + _remainingWhaleFunctionCalls[3] + _remainingWhaleFunctionCalls[4]);
    sealTokensLeft = (_remainingSealFunctionCalls[0] + _remainingSealFunctionCalls[1] + _remainingSealFunctionCalls[2] + _remainingSealFunctionCalls[3] + _remainingSealFunctionCalls[4]);
    planktonTokensLeft = (_remainingPlanktonFunctionCalls[0] + _remainingPlanktonFunctionCalls[1] + _remainingPlanktonFunctionCalls[2] + _remainingPlanktonFunctionCalls[3] + _remainingPlanktonFunctionCalls[4]);
    
    totalWhaleTokenAmount = (_remainingWhaleFunctionCalls[0] + _remainingWhaleFunctionCalls[1] + _remainingWhaleFunctionCalls[2] + _remainingWhaleFunctionCalls[3] + _remainingWhaleFunctionCalls[4]);
    totalSealTokenAmount = (_remainingSealFunctionCalls[0] + _remainingSealFunctionCalls[1] + _remainingSealFunctionCalls[2] + _remainingSealFunctionCalls[3] + _remainingSealFunctionCalls[4]);
    totalPlanktonTokenAmount = (_remainingPlanktonFunctionCalls[0] + _remainingPlanktonFunctionCalls[1] + _remainingPlanktonFunctionCalls[2] + _remainingPlanktonFunctionCalls[3] + _remainingPlanktonFunctionCalls[4]); 
//below depicts the amount of tokens that can be minted but not the token Ids... how to make them tokenIds?
    RarityTraitsByKey[MintType.Whale] = RemainingFunctionCalls(
        _remainingWhaleFunctionCalls[0], //1 
        _remainingWhaleFunctionCalls[0] + _remainingWhaleFunctionCalls[1], //3
        _remainingWhaleFunctionCalls[0] + _remainingWhaleFunctionCalls[1] + _remainingWhaleFunctionCalls[2], 
        _remainingWhaleFunctionCalls[3], 
        _remainingWhaleFunctionCalls[4]);

    RarityTraitsByKey[MintType.Seal] = RemainingFunctionCalls(
        _remainingSealFunctionCalls[0], 
        _remainingSealFunctionCalls[0] + _remainingSealFunctionCalls[1], 
        _remainingSealFunctionCalls[0] + _remainingSealFunctionCalls[1] + _remainingSealFunctionCalls[2], 
        _remainingSealFunctionCalls[0] + _remainingSealFunctionCalls[1] + _remainingSealFunctionCalls[2] + _remainingSealFunctionCalls[3], 
        _remainingSealFunctionCalls[4]);
    
    RarityTraitsByKey[MintType.Plankton] = RemainingFunctionCalls(
        _remainingPlanktonFunctionCalls[0], 
        _remainingPlanktonFunctionCalls[0] + _remainingPlanktonFunctionCalls[1], 
        _remainingPlanktonFunctionCalls[0] + _remainingPlanktonFunctionCalls[1] + _remainingPlanktonFunctionCalls[2], 
        _remainingPlanktonFunctionCalls[0] + _remainingPlanktonFunctionCalls[1] + _remainingPlanktonFunctionCalls[2] + _remainingPlanktonFunctionCalls[3], 
        _remainingPlanktonFunctionCalls[0] + _remainingPlanktonFunctionCalls[1] + _remainingPlanktonFunctionCalls[2] + _remainingPlanktonFunctionCalls[3] + _remainingPlanktonFunctionCalls[4]);
  }

  function _baseURI() internal view override returns (string memory) {
    return URI;
  }

  function _safeMint(address to, uint256 tokenId) override internal virtual {
    _safeMint(to, tokenId, "");
  }

  function getRandomNumber(uint256 tokensLeft, uint256 tokensToPickFrom) internal view returns (uint256 randomNumber) {
    uint256 i = uint256(uint160(address(msg.sender)));
    // Wouldn't it change depending on block difficulty? Maybe it's not working becauase it's a test environement with hardhat
    // Maybe to makke this testeable we can do something like:
    randomNumber = ((block.difficulty + block.timestamp) + i / tokensLeft) % tokensToPickFrom + 1;
    //in the end, we only need the numerator to be random correct?
    // Hey man sorry, I have to go. The internet is kkinda bad and I'm taking up bandwidth
    // we can maybe continue through text?
    // ok, let's set up a time to go over this again. I might even try to play with it and run it locally.
    // I'll do taht this week. Can you point me to what the biggest problem is? sure.
  }

  function mintFromRandomNumber(uint256 randomNumber, MintType mintType, uint256 startingPointForTokenIds) public {
    if (randomNumber <= (startingPointForTokenIds + RarityTraitsByKey[mintType].Mycelia) && randomNumber > startingPointForTokenIds && RarityTraitsByKey[mintType].Mycelia > 0) {     
      myceliaMint(mintType, startingPointForTokenIds);
    } else if (randomNumber <= (startingPointForTokenIds + RarityTraitsByKey[mintType].Obsidian) && randomNumber > (startingPointForTokenIds + RarityTraitsByKey[mintType].Mycelia) && RarityTraitsByKey[mintType].Obsidian > 0) {
      obsidianMint(mintType, startingPointForTokenIds);
    } else if (randomNumber <= (startingPointForTokenIds + RarityTraitsByKey[mintType].Diamond) && randomNumber > (startingPointForTokenIds + RarityTraitsByKey[mintType].Obsidian) && RarityTraitsByKey[mintType].Diamond > 0) {
      diamondMint(mintType, startingPointForTokenIds);
    } else if (randomNumber <= (startingPointForTokenIds + RarityTraitsByKey[mintType].Gold) && randomNumber > (startingPointForTokenIds + RarityTraitsByKey[mintType].Diamond) && RarityTraitsByKey[mintType].Gold > 0) {
      goldMint(mintType, startingPointForTokenIds);
    } else if (randomNumber <= (startingPointForTokenIds + RarityTraitsByKey[mintType].Silver) && randomNumber > (startingPointForTokenIds + RarityTraitsByKey[mintType].Gold) && RarityTraitsByKey[mintType].Silver > 0) {
      silverMint(mintType, startingPointForTokenIds);
    }
  }

  function myceliaMint(MintType mintType, uint256 startingPointForTokenIds) public {
      _safeMint(msg.sender, (startingPointForTokenIds + RarityTraitsByKey[mintType].Mycelia));
      emit returnRarityByTokenId((startingPointForTokenIds + RarityTraitsByKey[mintType].Mycelia), "Mycelia");
      RarityTraitsByKey[mintType].Mycelia--;
  }

  function obsidianMint(MintType mintType, uint256 startingPointForTokenIds) public {
      _safeMint(msg.sender, (startingPointForTokenIds + RarityTraitsByKey[mintType].Obsidian));
      emit returnRarityByTokenId((startingPointForTokenIds + RarityTraitsByKey[mintType].Obsidian), "Obsidian");
      RarityTraitsByKey[mintType].Obsidian--;
  }

  function diamondMint(MintType mintType, uint256 startingPointForTokenIds) internal {
      _safeMint(msg.sender, (startingPointForTokenIds + RarityTraitsByKey[mintType].Diamond));
      emit returnRarityByTokenId((startingPointForTokenIds + RarityTraitsByKey[mintType].Diamond), "Diamond");
      RarityTraitsByKey[mintType].Diamond--;
  }

  function goldMint(MintType mintType, uint256 startingPointForTokenIds) internal {
      _safeMint(msg.sender, (startingPointForTokenIds + RarityTraitsByKey[mintType].Gold));
      emit returnRarityByTokenId((startingPointForTokenIds + RarityTraitsByKey[mintType].Gold), "Gold");
      RarityTraitsByKey[mintType].Gold--;
  }

  function silverMint(MintType mintType, uint256 startingPointForTokenIds) internal {
      _safeMint(msg.sender, (startingPointForTokenIds + RarityTraitsByKey[mintType].Silver));
      emit returnRarityByTokenId((startingPointForTokenIds + RarityTraitsByKey[mintType].Silver), "Silver"); 
      RarityTraitsByKey[mintType].Silver--;
  }

  function mintRandomWhaleNFT() public payable {
      //require(PRICE_PER_WHALE_TOKEN <= msg.value, "Ether value sent is not correct");
      require(whaleTokensLeft > 0, "Whale NFTs are sold out");
      uint256 randomNumber = getRandomNumber(whaleTokensLeft, totalWhaleTokenAmount);
      mintFromRandomNumber(randomNumber, MintType.Whale, 0);
      whaleTokensLeft--;
  }

  function mintRandomSealNFT() public payable {
      //require(PRICE_PER_SEAL_TOKEN <= msg.value, "Ether value sent is not correct");
      require(sealTokensLeft > 0, "Seal NFTs are sold out");
      uint256 randomNumber = totalWhaleTokenAmount + getRandomNumber(sealTokensLeft, totalSealTokenAmount);
      mintFromRandomNumber(randomNumber, MintType.Seal, totalWhaleTokenAmount);
      sealTokensLeft--;
  }

  function mintRandomPlanktonNFT() public payable {
      //require(PRICE_PER_PLANKTON_TOKEN <= msg.value, "Ether value sent is not correct");
      require(planktonTokensLeft > 0, "Plankton NFTs are sold out");
      uint256 randomNumber = (totalWhaleTokenAmount + totalSealTokenAmount) + getRandomNumber(planktonTokensLeft, totalPlanktonTokenAmount);
      mintFromRandomNumber(randomNumber, MintType.Plankton, (totalWhaleTokenAmount + totalSealTokenAmount));
      planktonTokensLeft--;
   }
}