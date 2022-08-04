//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
@title MembershipNft
@author Marco Huberts & Javier Gonzalez
@dev Implementation of a Community Non Fungible Token using ERC721B.
*/

contract MembershipNft is ERC721 {

    uint256 public constant PRICE_PER_WHALE_TOKEN = 1.0 ether;
    uint256 public constant PRICE_PER_SEAL_TOKEN = 0.2 ether;
    uint256 public constant PRICE_PER_PLANKTON_TOKEN = 0.1 ether;
    string public URI;

    uint256 public whaleTokensLeft;
    uint256 public sealTokensLeft;
    uint256 public planktonTokensLeft;

    uint256 public startSealTokenId;
    uint256 public startPlanktonTokenId;

    mapping(MintType => RemainingTokenIds) public RarityTraitsByKey;

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
    struct RemainingTokenIds {
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
    uint256 _startSealTokenId,
    uint256 _startPlanktonTokenId,
    uint256[] memory _remainingWhaleFunctionCalls, //  [3, 12, 35, 0, 0] // [3, 6, 9, 0, 0] //[1, 2, 3, 0, 0]
    uint256[] memory _remainingSealFunctionCalls, //   [3, 18, 40, 90, 0] // [3, 6, 9, 12, 0] // [1, 2, 3, 4, 0]
    uint256[] memory _remainingPlanktonFunctionCalls //[4, 60, 125, 310, 2301] // [3, 6, 9, 12, 15] // [1, 2, 3, 4, 5]
  ) ERC721("MEMBERSHIP", "VMEMB") {
    URI = _URI;
    startSealTokenId = _startSealTokenId;
    startPlanktonTokenId = _startPlanktonTokenId;
    whaleTokensLeft = (_remainingWhaleFunctionCalls[0] + _remainingWhaleFunctionCalls[1] + _remainingWhaleFunctionCalls[2] + _remainingWhaleFunctionCalls[3] + _remainingWhaleFunctionCalls[4]);
    sealTokensLeft = (_remainingSealFunctionCalls[0] + _remainingSealFunctionCalls[1] + _remainingSealFunctionCalls[2] + _remainingSealFunctionCalls[3] + _remainingSealFunctionCalls[4]);
    planktonTokensLeft = (_remainingPlanktonFunctionCalls[0] + _remainingPlanktonFunctionCalls[1] + _remainingPlanktonFunctionCalls[2] + _remainingPlanktonFunctionCalls[3] + _remainingPlanktonFunctionCalls[4]); 
    
    RarityTraitsByKey[MintType.Whale] = RemainingTokenIds(
        _remainingWhaleFunctionCalls[0], 
        _remainingWhaleFunctionCalls[0] + _remainingWhaleFunctionCalls[1], 
        _remainingWhaleFunctionCalls[0] + _remainingWhaleFunctionCalls[1] + _remainingWhaleFunctionCalls[2], 
        _remainingWhaleFunctionCalls[3], 
        _remainingWhaleFunctionCalls[4]);

      RarityTraitsByKey[MintType.Seal] = RemainingTokenIds(
        startSealTokenId + _remainingSealFunctionCalls[0], 
        startSealTokenId + _remainingSealFunctionCalls[0] + _remainingSealFunctionCalls[1], 
        startSealTokenId + _remainingSealFunctionCalls[0] + _remainingSealFunctionCalls[1] + _remainingSealFunctionCalls[2], 
        startSealTokenId + _remainingSealFunctionCalls[0] + _remainingSealFunctionCalls[1] + _remainingSealFunctionCalls[2] + _remainingSealFunctionCalls[3], 
        _remainingSealFunctionCalls[4]);
    
    RarityTraitsByKey[MintType.Plankton] = RemainingTokenIds(
        startPlanktonTokenId + _remainingPlanktonFunctionCalls[0], 
        startPlanktonTokenId + _remainingPlanktonFunctionCalls[0] + _remainingPlanktonFunctionCalls[1], 
        startPlanktonTokenId + _remainingPlanktonFunctionCalls[0] + _remainingPlanktonFunctionCalls[1] + _remainingPlanktonFunctionCalls[2], 
        startPlanktonTokenId + _remainingPlanktonFunctionCalls[0] + _remainingPlanktonFunctionCalls[1] + _remainingPlanktonFunctionCalls[2] + _remainingPlanktonFunctionCalls[3], 
        startPlanktonTokenId + _remainingPlanktonFunctionCalls[0] + _remainingPlanktonFunctionCalls[1] + _remainingPlanktonFunctionCalls[2] + _remainingPlanktonFunctionCalls[3] + _remainingPlanktonFunctionCalls[4]);

  }

  function _baseURI() internal view override returns (string memory) {
    return URI;
  }

  function _safeMint(address to, uint256 tokenId) override internal virtual {
        _safeMint(to, tokenId, "");
  }

  function getRandomNumber(uint256 tokensToPickFrom, uint256 tokenIdStart) internal view returns (uint256 randomNumber) {
    uint256 i = uint256(uint160(address(msg.sender)));
    randomNumber = tokenIdStart + (block.difficulty + i / tokensToPickFrom) % tokensToPickFrom + 1;
  }

  function getRarityFromRandomNumber(uint256 randomNumber, MintType mintType) internal view returns (Rarity rarity) {
    //not 3 mycelia left but 3 diamond
    //if the whale tokens left is down to 3, but e.g. 3 diamond nfts are left for minting then the random number will be  < 3 + 1 
    //which does not pick a diamond nft anymore because of the logic below
    if (randomNumber <= RarityTraitsByKey[mintType].Mycelia) { // add expression logic from whale minting function
        // randomnumber <= 3
        // randomnumber <= 15
        // randomnumber <= 50
        //let's say after 47 function calls 3 diamond nfts are left -> it should pick the leftover tokens
        // then randomnumber can only be < 3 + 1 but it does not pick a diamond nft anymore -> it should pick the leftover tokens
        
      rarity = Rarity.Mycelia;
    } else if (randomNumber <= RarityTraitsByKey[mintType].Obsidian) {
      rarity = Rarity.Obsidian;
    } else if (randomNumber <= RarityTraitsByKey[mintType].Diamond) {
      rarity = Rarity.Diamond;
    } else if (randomNumber <= RarityTraitsByKey[mintType].Gold) {
      rarity = Rarity.Gold;
    } else if (randomNumber <= RarityTraitsByKey[mintType].Silver) {
      rarity = Rarity.Silver;
    }
  }

  function getSelectedRarity(uint256 randomNumber, MintType mintType, Rarity newRarity) internal view returns (Rarity rarity) {
    if (randomNumber < RarityTraitsByKey[mintType].Mycelia) {
      rarity = newRarity;
    } else if (randomNumber < RarityTraitsByKey[mintType].Obsidian) {
      rarity = newRarity;
    } else if (randomNumber < RarityTraitsByKey[mintType].Diamond) {
      rarity = newRarity;
    } else if (randomNumber < RarityTraitsByKey[mintType].Gold) {
      rarity = newRarity;
    } else if (randomNumber < RarityTraitsByKey[mintType].Silver) {
      rarity = newRarity;
    }
  }

//   function pickMintingFunction(Rarity rarity, MintType mintType, uint256 tokensToPickFrom, uint256 tokenIdStart, Rarity newRarity) internal {
//     if (rarity == Rarity.Mycelia) {
//       myceliaMint(mintType, tokensToPickFrom, tokenIdStart, newRarity);
//     } else if (rarity == Rarity.Obsidian) {
//       obsidianMint(mintType, tokensToPickFrom, tokenIdStart);
//     } else if (rarity == Rarity.Diamond) {
//       diamondMint(mintType, tokensToPickFrom, tokenIdStart);
//     } else if (rarity == Rarity.Gold) {
//       goldMint(mintType, tokensToPickFrom, tokenIdStart);
//     } else if (rarity == Rarity.Silver) {
//       silverMint(mintType, tokensToPickFrom, tokenIdStart);
//     }
//   }

  function createArrayofRarityIds(MintType mintType) internal view returns (uint256[5] memory array) {
    array = [RarityTraitsByKey[mintType].Mycelia, 
    RarityTraitsByKey[mintType].Obsidian, 
    RarityTraitsByKey[mintType].Diamond, 
    RarityTraitsByKey[mintType].Gold, 
    RarityTraitsByKey[mintType].Silver];
  }

  function anyMint(MintType mintType, uint256 rarity, uint256 selectedTokenId) internal {
    if (createArrayofRarityIds(mintType)[rarity] > 0) {
        _safeMint(msg.sender, createArrayofRarityIds(mintType)[rarity]);
        emit returnRarityByTokenId(createArrayofRarityIds(mintType)[rarity], ""); 
        createArrayofRarityIds(mintType)[rarity]--;
    } else { 
        _safeMint(msg.sender, selectedTokenId);
    }
  }

  function myceliaMint(MintType mintType, uint256 selectedTokenId) internal {
    if (RarityTraitsByKey[mintType].Mycelia > 0) {//how can I prevent revert and let it mint obsidian or diamond in case of whale function call
        _safeMint(msg.sender, RarityTraitsByKey[mintType].Mycelia);//0
        emit returnRarityByTokenId(RarityTraitsByKey[mintType].Mycelia, "Mycelia"); 
        RarityTraitsByKey[mintType].Mycelia--;
    } else {
        _safeMint(msg.sender, selectedTokenId);
    }
  }

  function obsidianMint(MintType mintType, uint256 selectedTokenId) internal {
    if (RarityTraitsByKey[mintType].Obsidian > 0) {
        _safeMint(msg.sender, RarityTraitsByKey[mintType].Obsidian);
        emit returnRarityByTokenId(RarityTraitsByKey[mintType].Obsidian, "Obsidian"); 
        RarityTraitsByKey[mintType].Obsidian--;
    } else {
        _safeMint(msg.sender, selectedTokenId);
    }
  }

  function diamondMint(MintType mintType, uint256 selectedTokenId) internal {
    if (RarityTraitsByKey[mintType].Diamond > 0) {
        _safeMint(msg.sender, RarityTraitsByKey[mintType].Diamond);
        emit returnRarityByTokenId(RarityTraitsByKey[mintType].Diamond, "Diamond"); 
        RarityTraitsByKey[mintType].Diamond--;
    } else {
        _safeMint(msg.sender, selectedTokenId);
    }
  }

  function goldMint(MintType mintType, uint256 selectedTokenId) internal {
    if (RarityTraitsByKey[mintType].Gold > 0) {
        _safeMint(msg.sender, RarityTraitsByKey[mintType].Gold);
        emit returnRarityByTokenId(RarityTraitsByKey[mintType].Gold, "Gold"); 
        RarityTraitsByKey[mintType].Gold--;
    } else {
        _safeMint(msg.sender, selectedTokenId);
    }
  }

  function silverMint(MintType mintType, uint256 selectedTokenId) internal {
    if (RarityTraitsByKey[mintType].Silver > 0) {
        _safeMint(msg.sender, RarityTraitsByKey[mintType].Silver);
        emit returnRarityByTokenId(RarityTraitsByKey[mintType].Silver, "Silver"); 
        RarityTraitsByKey[mintType].Silver--;
    } else {
        _safeMint(msg.sender, selectedTokenId);
    }
  }
//   function myceliaMint(MintType mintType, uint256 tokensToPickFrom, uint256 tokenIdStart, Rarity newRarity) internal {
//     if (RarityTraitsByKey[mintType].Mycelia > 0) {
//         _safeMint(msg.sender, RarityTraitsByKey[mintType].Mycelia);
//         emit returnRarityByTokenId(RarityTraitsByKey[mintType].Mycelia, "Mycelia"); 
//         RarityTraitsByKey[mintType].Mycelia--;
//     } else { 
//         pickMintingFunction(getSelectedRarity(getRandomNumber(tokensToPickFrom, 0), mintType, newRarity), mintType, tokensToPickFrom, tokenIdStart, newRarity);
//     }
//   }

//   function obsidianMint(MintType mintType, uint256 tokensToPickFrom, uint256 tokenIdStart, Rarity newRarity) internal {
//     if (RarityTraitsByKey[mintType].Obsidian > 0) {
//         _safeMint(msg.sender, RarityTraitsByKey[mintType].Obsidian);
//         emit returnRarityByTokenId(RarityTraitsByKey[mintType].Obsidian, "Obsidian"); 
//         RarityTraitsByKey[mintType].Obsidian--;
//     } else {
//         pickMintingFunction(getRarityFromRandomNumber(getRandomNumber(tokensToPickFrom, 0), mintType), mintType, tokensToPickFrom, tokenIdStart, newRarity);
//     }

//   }

//   function diamondMint(MintType mintType, uint256 tokensToPickFrom, uint256 tokenIdStart, Rarity newRarity) internal {
//     if (RarityTraitsByKey[mintType].Diamond > 0) {
//         _safeMint(msg.sender, RarityTraitsByKey[mintType].Diamond);
//         emit returnRarityByTokenId(RarityTraitsByKey[mintType].Diamond, "Diamond"); 
//         RarityTraitsByKey[mintType].Diamond--;
//     } else {
//         pickMintingFunction(getRarityFromRandomNumber(getRandomNumber(tokensToPickFrom, 0), mintType), mintType, tokensToPickFrom, tokenIdStart, newRarity);
//     }
//   }

//   function goldMint(MintType mintType, uint256 tokensToPickFrom, uint256 tokenIdStart, Rarity newRarity) internal {
//     if (RarityTraitsByKey[mintType].Gold > 0) {
//         _safeMint(msg.sender, RarityTraitsByKey[mintType].Gold);
//         emit returnRarityByTokenId(RarityTraitsByKey[mintType].Gold, "Gold"); 
//         RarityTraitsByKey[mintType].Gold--;
//     } else {
//         pickMintingFunction(getRarityFromRandomNumber(getRandomNumber(tokensToPickFrom, 0), mintType), mintType, tokensToPickFrom, tokenIdStart, newRarity);
//     }
//   }

//   function silverMint(MintType mintType, uint256 tokensToPickFrom, uint256 tokenIdStart, Rarity newRarity) internal {
//     if (RarityTraitsByKey[mintType].Silver > 0) {
//         _safeMint(msg.sender, RarityTraitsByKey[mintType].Silver);
//         emit returnRarityByTokenId(RarityTraitsByKey[mintType].Silver, "Silver"); 
//         RarityTraitsByKey[mintType].Silver--;
//     } else {
//         pickMintingFunction(getRarityFromRandomNumber(getRandomNumber(tokensToPickFrom, 0), mintType), mintType, tokensToPickFrom, tokenIdStart, newRarity);
//     }
//   }

//   function getRarityByTokenId(uint256 _tokenId) external view returns(string memory rarity) {
//       if(turnRandomNumberIntoRarity(_tokenId) == Rarity.Mycelia) {
//           return rarity = "Mycelia";
//       } else if(turnRandomNumberIntoRarity(_tokenId) == Rarity.Obsidian) {
//           return rarity = "Obsidian";
//       } else if(turnRandomNumberIntoRarity(_tokenId) == Rarity.Diamond) {
//           return rarity = "Diamond";
//       } else if(turnRandomNumberIntoRarity(_tokenId) == Rarity.Gold) {
//           return rarity = "Gold";
//       } else if(turnRandomNumberIntoRarity(_tokenId) == Rarity.Silver) {
//           return rarity = "Silver";
//       }
//     }

//   function mintAny(MintType mintType) public {
//     if (createArrayofRarityIds(mintType)[0] > 0) {
//         _safeMint(msg.sender, RarityTraitsByKey[mintType].Mycelia);
//         emit returnRarityByTokenId(RarityTraitsByKey[mintType].Mycelia, "Mycelia");
//     } else if (RarityTraitsByKey[mintType].Obsidian > 0) {
//         _safeMint(msg.sender, RarityTraitsByKey[mintType].Obsidian);
//         emit returnRarityByTokenId(RarityTraitsByKey[mintType].Obsidian, "Obsidian");
//     } else if (RarityTraitsByKey[mintType].Diamond > 0) {
//         _safeMint(msg.sender, RarityTraitsByKey[mintType].Diamond);
//         emit returnRarityByTokenId(RarityTraitsByKey[mintType].Diamond, "Diamond");
//     } else if (RarityTraitsByKey[mintType].Gold > 0) {
//         _safeMint(msg.sender, RarityTraitsByKey[mintType].Gold);
//         emit returnRarityByTokenId(RarityTraitsByKey[mintType].Gold, "Gold");
//     } else if (RarityTraitsByKey[mintType].Silver > 0) {
//         _safeMint(msg.sender, RarityTraitsByKey[mintType].Silver);
//         emit returnRarityByTokenId(RarityTraitsByKey[mintType].Silver, "Silver"); 
//     } else {
//         revert("NFTs for this minting function are sold out");
//     }
//   }
//whale 1 to 50 seal 51 to 200 
//1 to 3 is mycelia, 3 to 15 
  function mintRandomWhaleNFT() public payable {
    // require(PRICE_PER_WHALE_TOKEN <= msg.value, "Ether value sent is not correct");
    require(whaleTokensLeft > 0, "Whale NFTs are sold out");
    uint256 randomNumber = getRandomNumber(whaleTokensLeft, 0);
    Rarity rarity = getRarityFromRandomNumber(randomNumber, MintType.Whale);

    if (rarity == Rarity.Mycelia && RarityTraitsByKey[MintType.Whale].Mycelia > 0) {
      myceliaMint(MintType.Whale, RarityTraitsByKey[MintType.Whale].Diamond);

    } else if (
      (rarity == Rarity.Mycelia && RarityTraitsByKey[MintType.Whale].Mycelia == 0) || 
      (rarity == Rarity.Obsidian && RarityTraitsByKey[MintType.Whale].Obsidian > 0)
      ) {
      obsidianMint(MintType.Whale, RarityTraitsByKey[MintType.Whale].Mycelia);

    } else if (
      ((rarity == Rarity.Mycelia && RarityTraitsByKey[MintType.Whale].Mycelia == 0) && 
      (rarity == Rarity.Obsidian && RarityTraitsByKey[MintType.Whale].Obsidian == 0)) || 
      rarity == Rarity.Diamond && RarityTraitsByKey[MintType.Whale].Diamond > 0) {
      diamondMint(MintType.Whale, RarityTraitsByKey[MintType.Whale].Obsidian);
    }
    whaleTokensLeft--;
  }

//   function mintRandomSealNFT() public payable {
//     uint256 i = uint256(uint160(address(msg.sender)));
//     uint256 sealTokenId = 50 + ((block.difficulty + i / sealTokensLeft) % sealTokensLeft + 1);
//     sealTokensLeft--;
//     require(PRICE_PER_SEAL_TOKEN == msg.value, "Ether value sent is not correct");

//     if (sealTokenId <= 53 && remaningSealMyceliaId >= 51) {
//       _safeMint(msg.sender, remaningSealMyceliaId, ''); 
//       remaningSealMyceliaId--;
//     } else if (sealTokenId <= 68 && remaningSealObsidianId >= 54) {
//       _safeMint(msg.sender, remaningSealObsidianId, '');
//       remaningSealObsidianId--;
//     } else if (sealTokenId <= 125 && remaningSealDiamondId >= 69) {
//       _safeMint(msg.sender, remaningSealDiamondId, ''); 
//       remaningSealDiamondId--;
//     } else if (sealTokenId <= 200 && remaningSealGoldId >= 126) {
//       _safeMint(msg.sender, remaningSealGoldId, ''); 
//       remaningSealGoldId--;
//     }
//   }

//   function mintRandomPlanktonNFT() public payable {
//     uint256 i = uint256(uint160(address(msg.sender)));
//     uint256 planktonTokenId = 200 + ((block.difficulty + i / planktonTokensLeft) % planktonTokensLeft + 1);
//     planktonTokensLeft--; 
//     require(PRICE_PER_PLANKTON_TOKEN == msg.value, "Ether value sent is not correct");

//     if (planktonTokenId <= 203 && remaningPlanktonMyceliaId >= 201) {
//       _safeMint(msg.sender, remaningPlanktonMyceliaId, '');
//       remaningPlanktonMyceliaId--;
//     } else if (planktonTokenId <= 223 && remaningPlanktonObsidianId >= 204) {
//       _safeMint(msg.sender, remaningPlanktonObsidianId, ''); 
//       remaningPlanktonObsidianId--;
//     } else if (planktonTokenId <= 375  && remaningPlanktonDiamondId >= 224) {
//       _safeMint(msg.sender, remaningPlanktonDiamondId, '');
//       remaningPlanktonDiamondId--;
//     } else if (planktonTokenId <= 1300 && remaningPlanktonGoldId >= 376) {
//       _safeMint(msg.sender, remaningPlanktonGoldId, ''); 
//       remaningPlanktonGoldId--;
//     } else if (planktonTokenId <= 3000 && remaningPlanktonSilverId >= 1301) {
//       _safeMint(msg.sender, remaningPlanktonSilverId, ''); 
//       remaningPlanktonSilverId--;
//     }
  // }
}