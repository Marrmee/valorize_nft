//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
@title MembershipNft
@author Marco Huberts & Javier Gonzalez
@dev Implementation of a Membership Non Fungible Token using ERC721.
*/

contract MembershipNft is ERC721{

    string public URI;
    uint256 public whaleTokensLeft;
    uint256 public sealTokensLeft;
    uint256 public planktonTokensLeft;
    uint256 public constant PRICE_PER_WHALE_TOKEN = 1.0 ether;
    uint256 public constant PRICE_PER_SEAL_TOKEN = 0.2 ether;
    uint256 public constant PRICE_PER_PLANKTON_TOKEN = 0.1 ether;
    uint256[] public numberOfFunctionCallsPerRarity;

      // mycelia is tokenId  1 - 12 // this needs to keep track of how many Mycelia NFTs have been minted per each minting function.
      // obsidian is tokenId 13 - 63 
      // gold                64 - 250 

      //a plankton can mint a mycelia, gold, diamond, silver, obsidian
      //a seal can mint a mycelia, diamond, obsidian gold
      //a whale can mint a mycelia, diamond, obsidian

  //1 to 3; 50 to 53; 200 to 203
  /*
  remaininghaleMintType.TokenIds
  struct
      mycelia
      obsidian
      etc
  */
    mapping(uint256 => address) public myceliaArtists; 
    mapping(MintType => RemainingTokenIds) public RarityTraitsByKey;

    struct RemainingTokenIds {
      uint256 Mycelia;
      uint256 Obsidian;
      uint256 Diamond;
      uint256 Gold;
      uint256 Silver;
    }

    enum Rarity { Mycelia, Obsidian, Diamond, Gold, Silver }
    enum MintType { TokenIds, Whale, Seal, Plankton }

    event returnRarityByTokenId(uint256 tokenId, string rarity);

    constructor(
      string memory _URI, 
      uint256[] memory _remainingWhaleFunctionCalls, //  [3, 12, 35, 0, 0] // [3, 6, 9, 0, 0] //[1, 2, 3, 0, 0]
      uint256[] memory _remainingSealFunctionCalls, //   [3, 18, 40, 90, 0] // [3, 6, 9, 12, 0] // [1, 2, 3, 4, 0]
      uint256[] memory _remainingPlanktonFunctionCalls //[4, 60, 125, 310, 2301] // [3, 6, 9, 12, 15] // [1, 2, 3, 4, 5]

      // [10, 90, 200, 400, 2300] -- total
      // [3, 15, 35, 0, 0] -- whale
      // [3, 17, 40, 100, 0] -- seal
      // [4, 36, 125, 300, 2300] -- plankton
    
      /**       
      amounts     
                Mycelia Obsidian Diamond Gold Silver Total
        whale     3       15      35      0     0    50
        seal      3       17      40     90     0    150 
        plankton  4       60     125     310   2301  2800
        total     10      90     200     400   2301  3000

      tokenIds
               Mycelia Obsidian Diamond Gold Silver Total
        whale     3       15      35      0     0    50
        seal      3       17      40     90     0    150 
        plankton  4       60     125     310   2301  2800
        total     10      90     200     400   2301  3000

      */

    ) ERC721("ValorizeMembership", "VALORIZE_MEMBERSHIP") {

      URI = _URI;
      whaleTokensLeft = (_remainingWhaleFunctionCalls[0] + _remainingWhaleFunctionCalls[1] + _remainingWhaleFunctionCalls[2] + _remainingWhaleFunctionCalls[3] + _remainingWhaleFunctionCalls[4]);
      sealTokensLeft = (_remainingSealFunctionCalls[0] + _remainingSealFunctionCalls[1] + _remainingSealFunctionCalls[2] + _remainingSealFunctionCalls[3] + _remainingSealFunctionCalls[4]);
      planktonTokensLeft = (_remainingPlanktonFunctionCalls[0] + _remainingPlanktonFunctionCalls[1] + _remainingPlanktonFunctionCalls[2] + _remainingPlanktonFunctionCalls[3] + _remainingPlanktonFunctionCalls[4]); 

      numberOfFunctionCallsPerRarity = [(_remainingWhaleFunctionCalls[0] + _remainingSealFunctionCalls[0] + _remainingPlanktonFunctionCalls[0]),
                                        (_remainingWhaleFunctionCalls[1] + _remainingSealFunctionCalls[1] + _remainingPlanktonFunctionCalls[1]),
                                        (_remainingWhaleFunctionCalls[2] + _remainingSealFunctionCalls[2] + _remainingPlanktonFunctionCalls[2]),
                                        (_remainingWhaleFunctionCalls[3] + _remainingSealFunctionCalls[3] + _remainingPlanktonFunctionCalls[3]),
                                        (_remainingWhaleFunctionCalls[4] + _remainingSealFunctionCalls[4] + _remainingPlanktonFunctionCalls[4])];

      RarityTraitsByKey[MintType.TokenIds] = RemainingTokenIds(
        tokenIdsPerRarity(Rarity.Mycelia),
        tokenIdsPerRarity(Rarity.Obsidian), 
        tokenIdsPerRarity(Rarity.Diamond),  
        tokenIdsPerRarity(Rarity.Gold), 
        tokenIdsPerRarity(Rarity.Silver)); 
      RarityTraitsByKey[MintType.Whale] = RemainingTokenIds(
        _remainingWhaleFunctionCalls[0], 
        _remainingWhaleFunctionCalls[1], 
        _remainingWhaleFunctionCalls[2], 
        _remainingWhaleFunctionCalls[3], 
        _remainingWhaleFunctionCalls[4]);
      RarityTraitsByKey[MintType.Seal] = RemainingTokenIds(
        _remainingSealFunctionCalls[0], 
        _remainingSealFunctionCalls[1], 
        _remainingSealFunctionCalls[2], 
        _remainingSealFunctionCalls[3], 
        _remainingSealFunctionCalls[4]);
      RarityTraitsByKey[MintType.Plankton] = RemainingTokenIds(
        _remainingPlanktonFunctionCalls[0], 
        _remainingPlanktonFunctionCalls[1], 
        _remainingPlanktonFunctionCalls[2], 
        _remainingPlanktonFunctionCalls[3], 
        _remainingPlanktonFunctionCalls[4]);
    }

    function _baseURI() internal view override returns (string memory) {
      return URI;
    }

    function getTokenIdByRarity(Rarity rarity) internal view returns (uint256 tokenId) {
      if (rarity == Rarity.Mycelia) {
        return tokenId = RarityTraitsByKey[MintType.TokenIds].Mycelia;
      } else if(rarity == Rarity.Obsidian) {
        return tokenId = RarityTraitsByKey[MintType.TokenIds].Obsidian;
      } else if(rarity == Rarity.Diamond) {
        return tokenId = RarityTraitsByKey[MintType.TokenIds].Diamond;
      } else if(rarity == Rarity.Gold) {
        return tokenId = RarityTraitsByKey[MintType.TokenIds].Gold;
      } else if(rarity == Rarity.Silver) {
        return tokenId = RarityTraitsByKey[MintType.TokenIds].Silver;
      }
    }

    function _mintGeneral(Rarity rarity) internal {
        _safeMint(msg.sender, getTokenIdByRarity(rarity)); 
    }

    function myceliaMint(MintType mintType) internal {
      require(RarityTraitsByKey[MintType.TokenIds].Mycelia > 0, "Mycelia NFTs are sold out");
      _mintGeneral(Rarity.Mycelia);
      emit returnRarityByTokenId(getTokenIdByRarity(Rarity.Mycelia), "Mycelia");
      RarityTraitsByKey[MintType.TokenIds].Mycelia--;
      RarityTraitsByKey[mintType].Mycelia--; 
    }

    function obsidianMint(MintType mintType) internal {
      require(RarityTraitsByKey[MintType.TokenIds].Obsidian > 0, "Obsidian NFTs are sold out");
      _mintGeneral(Rarity.Obsidian);
      emit returnRarityByTokenId(getTokenIdByRarity(Rarity.Obsidian), "Obsidian");
      RarityTraitsByKey[MintType.TokenIds].Obsidian--;
      RarityTraitsByKey[mintType].Obsidian--; 
    }

    function diamondMint(MintType mintType) internal {
      require(RarityTraitsByKey[MintType.TokenIds].Diamond > 0, "Diamond NFTs are sold out");
      _mintGeneral(Rarity.Diamond);
      emit returnRarityByTokenId(getTokenIdByRarity(Rarity.Diamond), "Diamond");
      RarityTraitsByKey[MintType.TokenIds].Diamond--;
      RarityTraitsByKey[mintType].Diamond--;
    }

    function goldMint(MintType mintType) internal {
      require(RarityTraitsByKey[MintType.TokenIds].Gold > 0, "Gold NFTs are sold out");
      _mintGeneral(Rarity.Gold);
      emit returnRarityByTokenId(getTokenIdByRarity(Rarity.Gold), "Gold");
      RarityTraitsByKey[MintType.TokenIds].Gold--;
      RarityTraitsByKey[mintType].Gold--;      
    }
    
    function silverMint(MintType mintType) internal {
      require(RarityTraitsByKey[mintType].Silver > 0, "Silver NFTs are sold out");
      _mintGeneral(Rarity.Silver);
      emit returnRarityByTokenId(getTokenIdByRarity(Rarity.Silver), "Silver");
      RarityTraitsByKey[MintType.TokenIds].Silver--;
      RarityTraitsByKey[mintType].Silver--; 
    }
      /**            
                Mycelia Obsidian Diamond Gold Silver Total
        whale     3       13      34      0     0    50
        seal      3       17      40     90     0    150 
        plankton  4       60     126     310   2300  2800
        total     10      90     200     400   2300  3000
      */

    function tokenIdsPerRarity(Rarity rarity) internal view returns (uint256 amount) {
      if (rarity == Rarity.Mycelia) {
        amount = numberOfFunctionCallsPerRarity[0]; //10
      } else if (rarity == Rarity.Obsidian) {
        amount = numberOfFunctionCallsPerRarity[0] + numberOfFunctionCallsPerRarity[1]; //10 + 90 = 100
      } else if (rarity == Rarity.Diamond) {
        amount = numberOfFunctionCallsPerRarity[0] + numberOfFunctionCallsPerRarity[1] + numberOfFunctionCallsPerRarity[2]; // 10 + 90 + 200 = 300
      } else if (rarity == Rarity.Gold) {
        amount = numberOfFunctionCallsPerRarity[0] + numberOfFunctionCallsPerRarity[1] + numberOfFunctionCallsPerRarity[2] + numberOfFunctionCallsPerRarity[3]; // 10 + 90 + 200 + 400 = 700
      } else if (rarity == Rarity.Silver) {
        amount = numberOfFunctionCallsPerRarity[0] + numberOfFunctionCallsPerRarity[1] + numberOfFunctionCallsPerRarity[2] + numberOfFunctionCallsPerRarity[3] + numberOfFunctionCallsPerRarity[4]; 
      }
    }

    function getRandomNumber(uint256 tokensToPickFrom) internal view returns (uint256 randomNumber) {
      uint256 i = uint256(uint160(address(msg.sender)));
      randomNumber = (block.difficulty + i / tokensToPickFrom) % tokensToPickFrom + 1;
    }

    function turnRandomNumberIntoRarity(uint256 randomNumber) internal view returns (Rarity rarityReturn) {
      if (randomNumber <= tokenIdsPerRarity(Rarity.Mycelia) && randomNumber > 0) {
        rarityReturn = Rarity.Mycelia;
      } else if (randomNumber <= tokenIdsPerRarity(Rarity.Obsidian) && randomNumber > tokenIdsPerRarity(Rarity.Mycelia)) {
        rarityReturn = Rarity.Obsidian;
      } else if (randomNumber <= tokenIdsPerRarity(Rarity.Diamond) && randomNumber > tokenIdsPerRarity(Rarity.Obsidian)) {
        rarityReturn = Rarity.Diamond;
      } else if (randomNumber <= tokenIdsPerRarity(Rarity.Gold) && randomNumber > tokenIdsPerRarity(Rarity.Diamond)) {
        rarityReturn = Rarity.Gold;
      } else if (randomNumber <= tokenIdsPerRarity(Rarity.Silver) && randomNumber > tokenIdsPerRarity(Rarity.Gold)) {
        rarityReturn = Rarity.Silver;
      }
    } 

    function turnRandomNumberIntoNewRarity(uint256 randomNumber, Rarity newRarity) internal view returns (Rarity rarityReturn) {
      if (randomNumber <= tokenIdsPerRarity(Rarity.Mycelia) && randomNumber > 0) {
        rarityReturn = newRarity;
      } else if (randomNumber <= tokenIdsPerRarity(Rarity.Obsidian) && randomNumber > tokenIdsPerRarity(Rarity.Mycelia)) {
        rarityReturn = newRarity;
      } else if (randomNumber <= tokenIdsPerRarity(Rarity.Diamond) && randomNumber > tokenIdsPerRarity(Rarity.Obsidian)) {
        rarityReturn = newRarity;
      } else if (randomNumber <= tokenIdsPerRarity(Rarity.Gold) && randomNumber > tokenIdsPerRarity(Rarity.Diamond)) {
        rarityReturn = newRarity;
      } else if (randomNumber <= tokenIdsPerRarity(Rarity.Silver) && randomNumber > tokenIdsPerRarity(Rarity.Gold)) {
        rarityReturn = newRarity;
      }
    } 

  function mintTypeRequirements(MintType mintType) internal view returns(bool requirements) {
    if(mintType == MintType.Whale) {
      requirements = (RarityTraitsByKey[mintType].Mycelia > 0 
      && RarityTraitsByKey[mintType].Obsidian > 0 
      && RarityTraitsByKey[mintType].Diamond > 0);
      return requirements;
    } else if(mintType == MintType.Seal) {
      requirements = (RarityTraitsByKey[mintType].Mycelia > 0 
      && RarityTraitsByKey[mintType].Obsidian > 0 
      && RarityTraitsByKey[mintType].Diamond > 0 
      && RarityTraitsByKey[mintType].Gold > 0);
      return requirements;
    } else if(mintType == MintType.Plankton) {
      requirements = (RarityTraitsByKey[mintType].Mycelia > 0 
      && RarityTraitsByKey[mintType].Obsidian > 0 
      && RarityTraitsByKey[mintType].Diamond > 0 
      && RarityTraitsByKey[mintType].Gold > 0 
      && RarityTraitsByKey[mintType].Silver > 0);
      return requirements;
    }
  }

    function getRarity(uint256 randomNumber, MintType mintType) public view returns (Rarity rarity) {
      if (mintTypeRequirements(mintType)) {
        rarity = turnRandomNumberIntoRarity(randomNumber);
        return rarity;
      } else {
        rarity = turnRandomNumberIntoNewRarity(randomNumber, turnRandomNumberIntoRarity(randomNumber));
        return rarity;
      }
    }

    function callMintingFunction(Rarity rarity, MintType mintType) internal {
      if (rarity == Rarity.Mycelia) {
        myceliaMint(mintType);
      } else if (rarity == Rarity.Obsidian) {
        obsidianMint(mintType);
      } else if (rarity == Rarity.Diamond) {
        diamondMint(mintType);
      } else if (rarity == Rarity.Gold) {
        goldMint(mintType);
      } else if (rarity == Rarity.Silver) {
        silverMint(mintType);
      }
    }

    function mintRandomWhaleNFT() public payable {
      //require(PRICE_PER_WHALE_TOKEN <= msg.value, "Ether value sent is not correct");
      require(whaleTokensLeft > 0, "Whale NFTs are sold out");
      uint256 randomNumber = getRandomNumber(tokenIdsPerRarity(Rarity.Diamond));
      Rarity rarity = getRarity(randomNumber, MintType.Whale);

      if (rarity == Rarity.Mycelia) {
        callMintingFunction(rarity, MintType.Whale);

      } else if (rarity == Rarity.Obsidian) {
        callMintingFunction(rarity, MintType.Whale); 

      } else if (rarity == Rarity.Diamond) {
        callMintingFunction(rarity, MintType.Whale);
      }
      whaleTokensLeft--;
    }

    function mintRandomSealNFT() public payable {
      //require(PRICE_PER_SEAL_TOKEN <= msg.value, "Ether value sent is not correct");
      require(sealTokensLeft > 0, "Seal NFTs are sold out");
      uint256 randomNumber = getRandomNumber(tokenIdsPerRarity(Rarity.Gold));
      Rarity rarity = getRarity(randomNumber, MintType.Seal);

      if (rarity == Rarity.Mycelia) {
        callMintingFunction(rarity, MintType.Seal);

      } else if (rarity == Rarity.Obsidian) {
        callMintingFunction(rarity, MintType.Seal);

      } else if (rarity == Rarity.Diamond) {
        callMintingFunction(rarity, MintType.Seal);

      } else if (rarity == Rarity.Gold) {
        callMintingFunction(rarity, MintType.Seal);
      }
      sealTokensLeft--;
    }

    function mintRandomPlanktonNFT() public payable {
      //require(PRICE_PER_PLANKTON_TOKEN <= msg.value, "Ether value sent is not correct");
      require(planktonTokensLeft > 0, "Plankton NFTs are sold out");
      uint256 randomNumber = getRandomNumber(tokenIdsPerRarity(Rarity.Silver));
      Rarity rarity = getRarity(randomNumber, MintType.Seal);

      if (rarity == Rarity.Mycelia) {
        callMintingFunction(rarity, MintType.Plankton);

      } else if (rarity == Rarity.Obsidian) {
        callMintingFunction(rarity, MintType.Plankton);

      } else if (rarity == Rarity.Diamond) {
        callMintingFunction(rarity, MintType.Plankton);

      } else if (rarity == Rarity.Gold) {
        callMintingFunction(rarity, MintType.Plankton);

      } else if (rarity == Rarity.Silver) {
        callMintingFunction(rarity, MintType.Plankton);
      }
      planktonTokensLeft--;
    }
    /**
    *@dev  rarity of a token Id is returned using an event
    *@param _tokenId is the token Id of the NFT of interest
    */
    function getRarityByTokenId(uint256 _tokenId) external view returns(string memory rarity) {
      
      if(turnRandomNumberIntoRarity(_tokenId) == Rarity.Mycelia) {
          return rarity = "Mycelia";
      } else if(turnRandomNumberIntoRarity(_tokenId) == Rarity.Obsidian) {
          return rarity = "Obsidian";
      } else if(turnRandomNumberIntoRarity(_tokenId) == Rarity.Diamond) {
          return rarity = "Diamond";
      } else if(turnRandomNumberIntoRarity(_tokenId) == Rarity.Gold) {
          return rarity = "Gold";
      } else if(turnRandomNumberIntoRarity(_tokenId) == Rarity.Silver) {
          return rarity = "Silver";
      }
    }
}