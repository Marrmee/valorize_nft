//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import { IERC2981, IERC165 } from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "./WhiteListed.sol";


/**
@title MembershipNft
@author Marco Huberts & Javier Gonzalez
@dev Implementation of a Membership Non Fungible Token using ERC721.
*/

contract MembershipNft is ERC721, Ownable, IERC2981, WhiteListed {

  string public URI;
  address royaltyDistributorAddress;
  address addressProductNFTArtist;
  uint256 public constant PRICE_PER_WHALE_TOKEN = 1.0 ether;
  uint256 public constant PRICE_PER_SEAL_TOKEN = 0.2 ether;
  uint256 public constant PRICE_PER_PLANKTON_TOKEN = 0.1 ether;
  uint256 public whaleTokensLeft;
  uint256 public sealTokensLeft;
  uint256 public planktonTokensLeft;
  uint16[] remainingWhaleTokenIds;
  uint16[] remainingSealTokenIds;
  uint16[] remainingPlanktonTokenIds;

  mapping(uint256 => address) public myceliaArtists; 
  mapping(string => RemainingMints) public RarityTraitsByKey;

  struct RemainingMints {
    uint16 Mycelia;
    uint16 Obsidian;
    uint16 Diamond;
    uint16 Gold;
    uint16 Silver;
  }

  event returnRarityByTokenId(uint256 tokenId, string rarity);

  constructor(
    string memory _name, 
    string memory _symbol, 
    string memory _URI,
    uint16 _whaleTokensLeft,
    uint16 _sealTokensLeft,
    uint16 _planktonTokensLeft,
    uint16[] memory _remainingWhaleTokenIds,
    uint16[] memory _remainingSealTokenIds,
    uint16[] memory _remainingPlanktonTokenIds
  ) ERC721(_name, _symbol) {
    URI = _URI;
    whaleTokensLeft = _whaleTokensLeft;
    sealTokensLeft = _sealTokensLeft;
    planktonTokensLeft = _planktonTokensLeft;
    remainingWhaleTokenIds = _remainingWhaleTokenIds;
    remainingSealTokenIds = _remainingSealTokenIds;
    remainingPlanktonTokenIds = _remainingPlanktonTokenIds;
    RarityTraitsByKey["Whale"] = RemainingMints(remainingWhaleTokenIds[0], remainingWhaleTokenIds[1], remainingWhaleTokenIds[2], remainingWhaleTokenIds[3], remainingWhaleTokenIds[4]);
    RarityTraitsByKey["Seal"] = RemainingMints(remainingSealTokenIds[0], remainingSealTokenIds[1], remainingSealTokenIds[2], remainingSealTokenIds[3], remainingSealTokenIds[4]);
    RarityTraitsByKey["Plankton"] = RemainingMints(remainingPlanktonTokenIds[0], remainingPlanktonTokenIds[1], remainingPlanktonTokenIds[2], remainingPlanktonTokenIds[3], remainingPlanktonTokenIds[4]);
  }

  function _baseURI() internal view override returns (string memory) {
    return URI;
  }

  function _safeMint(address to, uint256 tokenId) override internal virtual {
        _safeMint(to, tokenId, "");
  }

  function mintRandomWhaleNFT() public payable {
    uint256 i = uint256(uint160(address(msg.sender)));
    uint256 whaleTokenId = (block.difficulty + i / whaleTokensLeft) % whaleTokensLeft + 1;

    bool whaleMyceliaNFTIsPicked = (whaleTokenId <= remainingWhaleTokenIds[0] && RarityTraitsByKey["Whale"].Mycelia > 0);
    bool whaleObsidianNFTIsPicked = (whaleTokenId <= remainingWhaleTokenIds[1] && RarityTraitsByKey["Whale"].Obsidian > RarityTraitsByKey["Whale"].Mycelia);
    bool whaleDiamondNFTIsPicked = (whaleTokenId <= remainingWhaleTokenIds[2] && RarityTraitsByKey["Whale"].Diamond > RarityTraitsByKey["Whale"].Obsidian);

    require(PRICE_PER_WHALE_TOKEN <= msg.value, "Ether value sent is not correct");
    if (whaleMyceliaNFTIsPicked) {
      _whaleMint(msg.sender, RarityTraitsByKey["Whale"].Mycelia, ''); 
      RarityTraitsByKey["Whale"].Mycelia--;
    } else if (whaleObsidianNFTIsPicked) {
      _whaleMint(msg.sender, RarityTraitsByKey["Whale"].Obsidian, ''); 
      RarityTraitsByKey["Whale"].Obsidian--;
    } else if (whaleDiamondNFTIsPicked) {
      _whaleMint(msg.sender, RarityTraitsByKey["Whale"].Diamond, ''); 
      RarityTraitsByKey["Whale"].Diamond--;
    }
    whaleTokensLeft--;
  }

  function mintRandomSealNFT() public payable {
    uint256 i = uint256(uint160(address(msg.sender)));
    uint256 sealTokenId = remainingWhaleTokenIds[2] + ((block.difficulty + i / sealTokensLeft) % sealTokensLeft + 1);

    bool sealMyceliaNFTIsPicked = sealTokenId <= remainingSealTokenIds[0] && RarityTraitsByKey["Seal"].Mycelia >= (remainingWhaleTokenIds[2] + 1); 
    bool sealObsidianNFTIsPicked = sealTokenId <= remainingSealTokenIds[1] && RarityTraitsByKey["Seal"].Obsidian >= (remainingSealTokenIds[0] + 1);
    bool sealDiamondNFTIsPicked = sealTokenId <= remainingSealTokenIds[2] && RarityTraitsByKey["Seal"].Diamond >= (remainingSealTokenIds[1] + 1);
    bool sealGoldNFTIsPicked = sealTokenId <= remainingSealTokenIds[3] && RarityTraitsByKey["Seal"].Gold >= (remainingSealTokenIds[2] + 1);

    require(PRICE_PER_SEAL_TOKEN <= msg.value, "Ether value sent is not correct");

    if (sealMyceliaNFTIsPicked) {
      _sealMint(msg.sender, RarityTraitsByKey["Seal"].Mycelia, ''); 
      RarityTraitsByKey["Seal"].Mycelia--;
    } else if (sealObsidianNFTIsPicked) {
      _sealMint(msg.sender, RarityTraitsByKey["Seal"].Obsidian, '');
      RarityTraitsByKey["Seal"].Obsidian--;
    } else if (sealDiamondNFTIsPicked) {
      _sealMint(msg.sender, RarityTraitsByKey["Seal"].Diamond, ''); 
      RarityTraitsByKey["Seal"].Diamond--;
    } else if (sealGoldNFTIsPicked) {
      _sealMint(msg.sender, RarityTraitsByKey["Seal"].Gold, ''); 
      RarityTraitsByKey["Seal"].Gold--;
    }
    sealTokensLeft--;
  }

  function mintRandomPlanktonNFT() public payable {
    uint256 i = uint256(uint160(address(msg.sender)));
    uint256 planktonTokenId = remainingSealTokenIds[3] + ((block.difficulty + i / planktonTokensLeft) % planktonTokensLeft + 1); 

    bool planktonMyceliaNFTIsPicked = planktonTokenId <= remainingPlanktonTokenIds[0] && RarityTraitsByKey["Plankton"].Mycelia >= (remainingSealTokenIds[3] + 1);
    bool planktonObsidianNFTIsPicked = planktonTokenId <= remainingPlanktonTokenIds[1] && RarityTraitsByKey["Plankton"].Obsidian >= (remainingPlanktonTokenIds[0] + 1);
    bool planktonDiamondNFTIsPicked = planktonTokenId <= remainingPlanktonTokenIds[2]  && RarityTraitsByKey["Plankton"].Diamond >= (remainingPlanktonTokenIds[1] + 1);
    bool planktonGoldNFTIsPicked = planktonTokenId <= remainingPlanktonTokenIds[3] && RarityTraitsByKey["Plankton"].Gold >= (remainingPlanktonTokenIds[2] + 1);
    bool planktonSilverNFTIsPicked = planktonTokenId <= remainingPlanktonTokenIds[4] && RarityTraitsByKey["Plankton"].Silver >= (remainingPlanktonTokenIds[3] + 1);

    require(PRICE_PER_PLANKTON_TOKEN <= msg.value, "Ether value sent is not correct");

    if (planktonMyceliaNFTIsPicked) {
      _planktonMint(msg.sender, RarityTraitsByKey["Plankton"].Mycelia, '');
      RarityTraitsByKey["Plankton"].Mycelia--;
    } else if (planktonObsidianNFTIsPicked) {
      _planktonMint(msg.sender, RarityTraitsByKey["Plankton"].Obsidian, ''); 
      RarityTraitsByKey["Plankton"].Obsidian--;
    } else if (planktonDiamondNFTIsPicked) {
      _planktonMint(msg.sender, RarityTraitsByKey["Plankton"].Diamond, '');
      RarityTraitsByKey["Plankton"].Diamond--;
    } else if (planktonGoldNFTIsPicked) {
      _planktonMint(msg.sender, RarityTraitsByKey["Plankton"].Gold, ''); 
      RarityTraitsByKey["Plankton"].Gold--;
    } else if (planktonSilverNFTIsPicked) {
      _planktonMint(msg.sender, RarityTraitsByKey["Plankton"].Silver, ''); 
      RarityTraitsByKey["Plankton"].Silver--;
    }
    planktonTokensLeft--;
  }

  function _whaleMint(address recipient, uint256 whaleTokenId, bytes memory data) internal {
    require(whaleTokenId >= 1 && whaleTokenId <= remainingWhaleTokenIds[2], "the whale NFTs are sold out");
    _safeMint(recipient, whaleTokenId, data);
  }

  function _sealMint(address recipient, uint256 sealTokenId, bytes memory data) internal {
    require(sealTokenId >= (remainingWhaleTokenIds[2] + 1) && sealTokenId <= remainingSealTokenIds[3], "the seal NFTs are sold out");
    _safeMint(recipient, sealTokenId, data);
  }

  function _planktonMint(address recipient, uint256 planktonTokenId, bytes memory data) internal {
    require(planktonTokenId >= (remainingSealTokenIds[3] + 1) && planktonTokenId <= remainingPlanktonTokenIds[4], "the plankton NFTs are sold out");
    _safeMint(recipient, planktonTokenId, data);
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, IERC165) returns (bool) {
    return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
  }

  /**
  * @dev  rarity of a token Id is returned using an event
  * @param _tokenId is the token Id of the NFT of interest
  */
  function getRarityByTokenId(uint256 _tokenId) external returns(string memory rarity) {
    if((_tokenId <= remainingWhaleTokenIds[0] && _tokenId > 0) && (_tokenId <= remainingSealTokenIds[0] && _tokenId > remainingWhaleTokenIds[2])) {
        emit returnRarityByTokenId(_tokenId, "Mycelia");
        return rarity = "Mycelia";
    } else if(_tokenId <= remainingWhaleTokenIds[0] && _tokenId > 0) {
        emit returnRarityByTokenId(_tokenId, "Obsidian");
        return rarity = "Obsidian";
    } else if(_tokenId <= remainingSealTokenIds[0] && _tokenId > remainingWhaleTokenIds[2]) {
        emit returnRarityByTokenId(_tokenId, "Diamond");
        return rarity = "Diamond";
    } else if(_tokenId <= remainingSealTokenIds[2] && _tokenId > remainingSealTokenIds[1]) {
        emit returnRarityByTokenId(_tokenId, "Gold");
        return rarity = "Gold";
    } else if(_tokenId > 0) {
        emit returnRarityByTokenId(_tokenId, "Silver");
        return rarity = "Silver";
    }
  }
  
  function allowListMint() external payable {
    require(isAllowListActive == true, "Allow list is not active");
    require(AllowList[msg.sender] == true, "you already minted an NFT");
    if (ChoiceList[msg.sender] == 1) {
      require(PRICE_PER_WHALE_TOKEN <= msg.value, "Ether value sent is not correct");
      mintRandomWhaleNFT();
      AllowList[msg.sender] = false;
    } else if (ChoiceList[msg.sender] == 2) {
      require(PRICE_PER_SEAL_TOKEN <= msg.value, "Ether value sent is not correct");
      mintRandomSealNFT();
      AllowList[msg.sender] = false;
    } else if (ChoiceList[msg.sender] == 3) {
      require(PRICE_PER_PLANKTON_TOKEN <= msg.value, "Ether value sent is not correct");
      mintRandomPlanktonNFT();
      AllowList[msg.sender] = false;
    }
  }

  
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
        if ((_tokenId <= remainingWhaleTokenIds[0]) || (_tokenId >= remainingWhaleTokenIds[2] && _tokenId <= remainingSealTokenIds[0]) 
            || (_tokenId >= remainingSealTokenIds[3] && _tokenId <= remainingPlanktonTokenIds[0])) {
            return(myceliaArtists[_tokenId], royaltyAmount);
        } else {
            return(royaltyDistributorAddress, royaltyAmount); 
        }
    }
//     // find out what artist token sold (only for member NFT)
//     // if token is mycelia, give 10% to artist
//     // else transfer 10% to smart contract that distributes royalties to that artist

}