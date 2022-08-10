//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { IERC2981, IERC165 } from "@openzeppelin/contracts/interfaces/IERC2981.sol";
//import "./WhiteListed.sol";


/**
@title MembershipNft
@author Marco Huberts & Javier Gonzalez
@dev Implementation of a Membership Non Fungible Token using ERC721.
*/

contract MembershipNft is ERC721, IERC2981 {

  string public URI;
  address royaltyDistributorAddress;
  address addressProductNFTArtist;
  uint256 public constant PRICE_PER_WHALE_TOKEN = 1.0 ether;
  uint256 public constant PRICE_PER_SEAL_TOKEN = 0.2 ether;
  uint256 public constant PRICE_PER_PLANKTON_TOKEN = 0.1 ether;
  uint256 public whaleTokensLeft;
  uint256 public sealTokensLeft;
  uint256 public planktonTokensLeft;
  uint16[] whaleTokenRarityIndices;
  uint16[] sealTokenRarityIndices;
  uint16[] planktonTokenRarityIndices;

  mapping(uint256 => address) public myceliaArtists; 
  mapping(string => RemainingMints) public RarityTraitsByKey;

  struct RemainingMints { //[3, 18, 50, 0, 0]
    uint16 Mycelia;
    uint16 Obsidian;
    uint16 Diamond;
    uint16 Gold;
    uint16 Silver;
  }

  event returnRarityByTokenId(uint256 tokenId, string rarity);

  //  [3, 12, 35, 0, 0] // [3, 6, 9, 0, 0] //[1, 2, 3, 0, 0]
 //   [3, 18, 40, 90, 0] // [3, 6, 9, 12, 0] // [1, 2, 3, 4, 0] [7, 9, 12, 16, 0]
//[4, 60, 125, 310, 2301] // [3, 6, 9, 12, 15] // [1, 2, 3, 4, 5] [17, 19, 22, 26, 31]

  constructor(
    string memory _URI,
    uint16 _whaleTokensLeft,
    uint16 _sealTokensLeft,
    uint16 _planktonTokensLeft,
    uint16[] memory _whaleTokenRarityIndices,
    uint16[] memory _sealTokenRarityIndices,
    uint16[] memory _planktonTokenRarityIndices
  ) ERC721("MEMBER", "MEMB") {
    URI = _URI;
    whaleTokensLeft = _whaleTokensLeft;
    sealTokensLeft = _sealTokensLeft;
    planktonTokensLeft = _planktonTokensLeft;
    whaleTokenRarityIndices = _whaleTokenRarityIndices;
    sealTokenRarityIndices = _sealTokenRarityIndices;
    planktonTokenRarityIndices = _planktonTokenRarityIndices;
    RarityTraitsByKey["Whale"] = RemainingMints(whaleTokenRarityIndices[0], whaleTokenRarityIndices[1], whaleTokenRarityIndices[2], whaleTokenRarityIndices[3], whaleTokenRarityIndices[4]);
    RarityTraitsByKey["Seal"] = RemainingMints(sealTokenRarityIndices[0], sealTokenRarityIndices[1], sealTokenRarityIndices[2], sealTokenRarityIndices[3], sealTokenRarityIndices[4]);
    RarityTraitsByKey["Plankton"] = RemainingMints(planktonTokenRarityIndices[0], planktonTokenRarityIndices[1], planktonTokenRarityIndices[2], planktonTokenRarityIndices[3], planktonTokenRarityIndices[4]);
  }

  function _baseURI() internal view override returns (string memory) {
    return URI;
  }

  function _selectiveMint(address recipient, uint256 tokenId) internal {
    if (tokenId >= 1 && tokenId <= whaleTokenRarityIndices[2]){
    _safeMint(recipient, tokenId, '');
    } else if (tokenId > (whaleTokenRarityIndices[2]) && tokenId <= sealTokenRarityIndices[3]) {
     _safeMint(recipient, tokenId, '');   
    } else if (tokenId > (sealTokenRarityIndices[3]) && tokenId <= planktonTokenRarityIndices[4]) {
     _safeMint(recipient, tokenId, '');      
    }
  }

  function mintRandomWhaleNFT() public payable {
    require(whaleTokensLeft > 0, "the whale NFTs are sold out");
    //require(PRICE_PER_WHALE_TOKEN <= msg.value, "Ether value sent is not correct");

    uint256 i = uint256(uint160(address(msg.sender)));
    uint256 whaleTokenId = (block.difficulty + i / whaleTokensLeft) % whaleTokensLeft + 1;

    bool whaleMyceliaNFTIsPicked = (whaleTokenId <= whaleTokenRarityIndices[0] && RarityTraitsByKey["Whale"].Mycelia > 0);
    bool whaleObsidianNFTIsPicked = (whaleTokenId <= whaleTokenRarityIndices[1] && RarityTraitsByKey["Whale"].Obsidian > RarityTraitsByKey["Whale"].Mycelia);
    bool whaleDiamondNFTIsPicked = (whaleTokenId <= whaleTokenRarityIndices[2] && RarityTraitsByKey["Whale"].Diamond > RarityTraitsByKey["Whale"].Obsidian);

    if (whaleMyceliaNFTIsPicked) {
        mintMycelia("Whale");

    } else if (whaleObsidianNFTIsPicked) {
        mintObsidian("Whale");

    } else if (whaleDiamondNFTIsPicked) {
        mintDiamond("Whale");

    }
    whaleTokensLeft--;
  }

  function mintRandomSealNFT() public payable {
    require(sealTokensLeft > 0, "the seal NFTs are sold out");
    //require(PRICE_PER_SEAL_TOKEN <= msg.value, "Ether value sent is not correct");
    
    uint256 i = uint256(uint160(address(msg.sender)));
    uint256 sealTokenId = whaleTokenRarityIndices[2] + ((block.difficulty + i / sealTokensLeft) % sealTokensLeft + 1);

    bool sealMyceliaNFTIsPicked = sealTokenId <= sealTokenRarityIndices[0] && RarityTraitsByKey["Seal"].Mycelia >= (whaleTokenRarityIndices[2] + 1); 
    bool sealObsidianNFTIsPicked = sealTokenId <= sealTokenRarityIndices[1] && RarityTraitsByKey["Seal"].Obsidian >= (sealTokenRarityIndices[0] + 1);
    bool sealDiamondNFTIsPicked = sealTokenId <= sealTokenRarityIndices[2] && RarityTraitsByKey["Seal"].Diamond >= (sealTokenRarityIndices[1] + 1);
    bool sealGoldNFTIsPicked = sealTokenId <= sealTokenRarityIndices[3] && RarityTraitsByKey["Seal"].Gold >= (sealTokenRarityIndices[2] + 1);

    if (sealMyceliaNFTIsPicked) {
        mintMycelia("Seal");

    } else if (sealObsidianNFTIsPicked) {
        mintObsidian("Seal");

    } else if (sealDiamondNFTIsPicked) {
        mintDiamond("Seal");

    } else if (sealGoldNFTIsPicked) {
        mintGold("Seal");
    }
    sealTokensLeft--;
  }

  function mintRandomPlanktonNFT() public payable {
    require(planktonTokensLeft > 0, "the plankton NFTs are sold out");
    //require(PRICE_PER_PLANKTON_TOKEN <= msg.value, "Ether value sent is not correct");

    uint256 i = uint256(uint160(address(msg.sender)));
    uint256 planktonTokenId = sealTokenRarityIndices[3] + ((block.difficulty + i / planktonTokensLeft) % planktonTokensLeft + 1); 

    bool planktonMyceliaNFTIsPicked = planktonTokenId <= planktonTokenRarityIndices[0] && RarityTraitsByKey["Plankton"].Mycelia >= (sealTokenRarityIndices[3] + 1);
    bool planktonObsidianNFTIsPicked = planktonTokenId <= planktonTokenRarityIndices[1] && RarityTraitsByKey["Plankton"].Obsidian >= (planktonTokenRarityIndices[0] + 1);
    bool planktonDiamondNFTIsPicked = planktonTokenId <= planktonTokenRarityIndices[2]  && RarityTraitsByKey["Plankton"].Diamond >= (planktonTokenRarityIndices[1] + 1);
    bool planktonGoldNFTIsPicked = planktonTokenId <= planktonTokenRarityIndices[3] && RarityTraitsByKey["Plankton"].Gold >= (planktonTokenRarityIndices[2] + 1);
    bool planktonSilverNFTIsPicked = planktonTokenId <= planktonTokenRarityIndices[4] && RarityTraitsByKey["Plankton"].Silver >= (planktonTokenRarityIndices[3] + 1);

    if (planktonMyceliaNFTIsPicked) {
        mintMycelia("Plankton");
    
    } else if (planktonObsidianNFTIsPicked) {
        mintObsidian("Plankton");

    } else if (planktonDiamondNFTIsPicked) {
        mintDiamond("Plankton");

    } else if (planktonGoldNFTIsPicked) {
        mintGold("Plankton");

    } else if (planktonSilverNFTIsPicked) {
        mintSilver();
    }
    planktonTokensLeft--;
  }

    function mintMycelia(string memory mintType) public {
        _selectiveMint(msg.sender, RarityTraitsByKey[mintType].Mycelia);
        emit returnRarityByTokenId(RarityTraitsByKey[mintType].Mycelia, "Mycelia");  
        RarityTraitsByKey[mintType].Mycelia--;
    }

    function mintObsidian(string memory mintType) public {
        _selectiveMint(msg.sender, RarityTraitsByKey[mintType].Obsidian);
        emit returnRarityByTokenId(RarityTraitsByKey[mintType].Obsidian, "Obsidian");  
        RarityTraitsByKey[mintType].Obsidian--;
    }

    function mintDiamond(string memory mintType) public {
        _selectiveMint(msg.sender, RarityTraitsByKey[mintType].Diamond);
        emit returnRarityByTokenId(RarityTraitsByKey[mintType].Diamond, "Diamond");  
        RarityTraitsByKey[mintType].Diamond--;
    }

    function mintGold(string memory mintType) public {
        _selectiveMint(msg.sender, RarityTraitsByKey[mintType].Diamond);
        emit returnRarityByTokenId(RarityTraitsByKey[mintType].Diamond, "Diamond");  
        RarityTraitsByKey[mintType].Diamond--;
    }

    function mintSilver() public {
      _selectiveMint(msg.sender, RarityTraitsByKey["Plankton"].Silver);
      emit returnRarityByTokenId(RarityTraitsByKey["Plankton"].Silver, "Silver"); 
      RarityTraitsByKey["Plankton"].Silver--;
    }


  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, IERC165) returns (bool) {
    return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
  }

  /**
  * @dev  rarity of a token Id is returned using an event
  * @param _tokenId is the token Id of the NFT of interest
  */
  function getRarityByTokenId(uint256 _tokenId) external view returns(string memory rarity) {
    //whale token Id 1 to 50
    //mycelia is token Id 1 to 3
    //seal token Id 50 to 200
    //mycelia is 50 to 53
    //plankton is token Id 200 to 3000 
    //mycelia is 200 to 203

    // mycelia is tokenId  1 - 12 // this needs to keep track of how many Mycelia NFTs have been minted per each minting function.
    // obsidian is tokenId 13 - 63 
    // gold                64 - 250 

    //a plankton can mint a mycelia, gold, diamond, silver, obsidian
    //a seal can mint a mycelia, diamond, obsidian gold
    //a whale can mint a mycelia, diamond, obsidian

//1 to 3; 50 to 53; 200 to 203
/*
remaininghaletokenIds
struct
    mycelia
    obsidian
    etc
*/

    bool myceliaTokenIdIsGiven = (_tokenId > 0 && _tokenId <= whaleTokenRarityIndices[0]) 
            || (_tokenId >= whaleTokenRarityIndices[2] && _tokenId <= sealTokenRarityIndices[0]) 
            || (_tokenId >= sealTokenRarityIndices[3] && _tokenId <= planktonTokenRarityIndices[0]);

    bool obsidianTokenIdIsGiven = (_tokenId >= whaleTokenRarityIndices[0] && _tokenId <= whaleTokenRarityIndices[1]) 
            || (_tokenId > sealTokenRarityIndices[0] && _tokenId <= sealTokenRarityIndices[1]) 
            || (_tokenId > planktonTokenRarityIndices[0] && _tokenId <= planktonTokenRarityIndices[2]);

    bool diamondTokenIdIsGiven = (_tokenId >= whaleTokenRarityIndices[1] && _tokenId <= whaleTokenRarityIndices[2]) 
            || (_tokenId > sealTokenRarityIndices[1] && _tokenId <= sealTokenRarityIndices[2]) 
            || (_tokenId > planktonTokenRarityIndices[1] && _tokenId <= planktonTokenRarityIndices[2]);

    bool goldTokenIdIsGiven = (_tokenId > sealTokenRarityIndices[2] && _tokenId <= sealTokenRarityIndices[3]) 
            || (_tokenId > planktonTokenRarityIndices[2] && _tokenId <= planktonTokenRarityIndices[3]);
            
    bool silverTokenIdIsGiven = (_tokenId > planktonTokenRarityIndices[3] && _tokenId <= planktonTokenRarityIndices[4]);

    if(myceliaTokenIdIsGiven) {
        return rarity = "Mycelia";
    } else if(obsidianTokenIdIsGiven) {
        return rarity = "Obsidian";
    } else if(diamondTokenIdIsGiven) {
        return rarity = "Diamond";
    } else if(goldTokenIdIsGiven) {
        return rarity = "Gold";
    } else if(silverTokenIdIsGiven) {
        return rarity = "Silver";
    }
  }
  
//   function allowListMint() external payable {
//     require(isAllowListActive == true, "Allow list is not active");
//     require(AllowList[msg.sender] == true, "you already minted an NFT");
//     if (ChoiceList[msg.sender] == 1) {
//       require(PRICE_PER_WHALE_TOKEN <= msg.value, "Ether value sent is not correct");
//       mintRandomWhaleNFT();
//       AllowList[msg.sender] = false;
//     } else if (ChoiceList[msg.sender] == 2) {
//       require(PRICE_PER_SEAL_TOKEN <= msg.value, "Ether value sent is not correct");
//       mintRandomSealNFT();
//       AllowList[msg.sender] = false;
//     } else if (ChoiceList[msg.sender] == 3) {
//       require(PRICE_PER_PLANKTON_TOKEN <= msg.value, "Ether value sent is not correct");
//       mintRandomPlanktonNFT();
//       AllowList[msg.sender] = false;
//     }
//   }

  
  function settingMyceliaArtists(address[] memory _artists, uint256[] memory _tokenIds) public {
    for(uint256 i = 0; i < _tokenIds.length; i++) {
      myceliaArtists[_tokenIds[i]] = _artists[i];
    }
  }

    /**
    * @dev  Information about the royalty is returned when provided with token Id and sale price 
    * @param _tokenId is the tokenId of an NFT that has been sold on the NFT marketplace
    * @param _salePrice is the price of the sale of the given tokenId
    */
  function royaltyInfo(
    uint256 _tokenId,
    uint256 _salePrice
  ) external view override returns (
    address,
    uint256 royaltyAmount
  ) {
    royaltyAmount = (_salePrice / 100) * 10;
      if ((_tokenId <= whaleTokenRarityIndices[0]) || (_tokenId >= whaleTokenRarityIndices[2] && _tokenId <= sealTokenRarityIndices[0]) 
         || (_tokenId >= sealTokenRarityIndices[3] && _tokenId <= planktonTokenRarityIndices[0])) {
         return(myceliaArtists[_tokenId], royaltyAmount);
      } else {
         return(royaltyDistributorAddress, royaltyAmount); 
      }
  }

}