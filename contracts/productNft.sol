//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

//import "./RoyaltyDistributor.sol";
import "./WhiteListed.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { IERC2981, IERC165 } from "@openzeppelin/contracts/interfaces/IERC2981.sol";

/**
@title MembershipNft
@author Marco Huberts & Javier Gonzalez
@dev    Implementation of a Valorize Product Non Fungible Token using ERC721.
*       Key information: have the metadata ordered from token Id 1 to 2010 
*       whereby token Id 1 to 10 are Mycelia, token Id 10 to 110 Obsidian, 
*       token Id 110 to 360 Diamond, token Id 360 to 1010 Gold & token Id 1010 to 2010 Silver.
*       Rarer mint function token Id will start from 10 & Rare mint function token Id will start from 1010.
*       Numbers can change but the token Ids should be in the order mentioned above.
* Avoid having to do math on parameters that will be sent by humans (constructor)
* Try to minimize the state modifications that you do (It's fine, but if you can avoid it it's better, if you can't avoid it, writing to state once is better than writing to state 5 times)
* Try to make functions that are similar into reusable bits (don't overoptimize for this)
* Remember to name things correctly [https://martinfowler.com/bliki/TwoHardThings.html]
*/

contract ProductNft is ERC721, IERC2981, Ownable {
  string public URI;
  uint256 public constant PRICE_PER_RAREST_TOKEN = 1.5 ether;
  uint256 public constant PRICE_PER_RARER_TOKEN = 0.55 ether;
  uint256 public constant PRICE_PER_RARE_TOKEN = 0.2 ether;
  uint256 public rarestTokensLeft;
  uint256 public rareTokensLeft;
  uint16 public startRarerTokenId;
  uint16 public startRareTokenId;
  uint16[] remainingRarerTokenIds;
  address royaltyDistributorAddress;
  address addressProductNFTArtist;

  mapping(string => RemainingRarerMints) public RarityTraitsByKey;

  struct RemainingRarerMints {
    uint16 Obsidian;
    uint16 Diamond;
    uint16 Gold;
  }

  event returnRarityByTokenId(uint256 tokenId, string rarity);
  //event royaltyInformation(address receiver, uint256 royaltyAmount);

  constructor(    
    string memory _name, 
    string memory _symbol, 
    string memory _URI,
    uint16 _startRarerTokenId,
    uint16 _startRareTokenId,
    uint16 _rarestTokensLeft,
    uint16 _rareTokensLeft,
    uint16[] memory _remainingRarerTokenIds
    ) ERC721(_name, _symbol) {
        URI = _URI;
        startRarerTokenId = _startRarerTokenId;
        startRareTokenId = _startRareTokenId;
        rarestTokensLeft = _rarestTokensLeft;
        rareTokensLeft = _rareTokensLeft;
        remainingRarerTokenIds = _remainingRarerTokenIds; 
        RarityTraitsByKey["Rarer"] = RemainingRarerMints(remainingRarerTokenIds[0], remainingRarerTokenIds[1], remainingRarerTokenIds[2]);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, IERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    function _baseURI() internal view override returns (string memory) {
        return URI;
    }

    function _safeMint(address to, uint256 tokenId) override internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
    * @dev  This minting function allows the minting of Rarest tokenIds 10 to 1.
    *       These tokenIds are associated with the Mycelia rarity.
    *       Every call will decrement the tokenId (starting from 10). 
    *       This function can be called for 1.5 ETH.
    */
    function rarestMint() public payable {
        uint256 rarestTokenId = rarestTokensLeft;
        require(rarestTokenId > 0, "rarest NFTs are sold out");
        require(PRICE_PER_RAREST_TOKEN <= msg.value, "Ether value sent is not correct");
        _safeMint(msg.sender, rarestTokenId, " ");
        emit returnRarityByTokenId(rarestTokensLeft, "Mycelia"); 
        rarestTokensLeft--;
    }

    /**
    * @dev  This minting function allows the minting of Rarer token Ids 10 to 1010.
    *       These tokenIds are minted in the following order:
    *       Obsidian (token Ids 10 to 110), Diamond (token Ids 110 to 360) & Gold (token Ids 360 to 1010)
    *       Every call will increment the tokenId (starting from 10). 
    *       This function can be called for 0.55 ETH.
    */
    function rarerOrderMint() public payable {
        uint256 rarerTokenId = startRarerTokenId + 1;
        require(rarerTokenId < startRareTokenId, "Rarer Product NFTs are sold out");
        require(PRICE_PER_RARER_TOKEN <= msg.value, "Ether value sent is not correct");
        
        bool obsidianNFTsAreFirst = (rarerTokenId <= remainingRarerTokenIds[0] && RarityTraitsByKey["Rarer"].Obsidian > (startRarerTokenId));
        bool diamondNFTsAreAfter = (rarerTokenId <= remainingRarerTokenIds[1] && RarityTraitsByKey["Rarer"].Diamond > (remainingRarerTokenIds[0]));
        bool goldNFTsAreLast = (rarerTokenId <= remainingRarerTokenIds[2] && RarityTraitsByKey["Rarer"].Obsidian > remainingRarerTokenIds[1]);

        if (obsidianNFTsAreFirst) {
            _safeMint(msg.sender, RarityTraitsByKey["Rarer"].Obsidian, '');
            emit returnRarityByTokenId(RarityTraitsByKey["Rarer"].Obsidian, "Obsidian"); 
            RarityTraitsByKey["Rarer"].Obsidian--;
        } else if (diamondNFTsAreAfter) {
            _safeMint(msg.sender, RarityTraitsByKey["Rarer"].Diamond, '');
            emit returnRarityByTokenId(RarityTraitsByKey["Rarer"].Diamond, "Diamond"); 
            RarityTraitsByKey["Rarer"].Diamond--;
        } else if (goldNFTsAreLast) {
            _safeMint(msg.sender, RarityTraitsByKey["Rarer"].Gold, '');
            emit returnRarityByTokenId(RarityTraitsByKey["Rarer"].Gold, "Gold");  
            RarityTraitsByKey["Rarer"].Gold--;
        }
        startRarerTokenId++;
    }

    /**
    * @dev  This minting function allows the minting of Rare tokenIds 1010 to 2010.
    *       These tokenIds are associated with the Mycelia rarity.
    *       Every call will decrement the tokenId (starting from token Id 2010). 
    *       This function can be called for 0.2 ETH.
    */
    function rareMint() public payable {
        uint256 rareTokenId = startRareTokenId + rareTokensLeft;
        require(rareTokenId > startRareTokenId, "Rare Product NFTs are sold out");
        require(PRICE_PER_RARE_TOKEN <= msg.value, "Ether value sent is not correct");
        _safeMint(msg.sender, rareTokenId, " ");
        emit returnRarityByTokenId(rareTokenId, "Silver"); 
        rareTokensLeft--;
    }

    /**
    * @dev  rarity of a token Id is returned using an event
    * @param _tokenId is the token Id of the NFT of interest
    */
    function getRarityByTokenId(uint256 _tokenId) external returns(string memory rarity) {
        if(_tokenId < startRarerTokenId) {
            emit returnRarityByTokenId(_tokenId, "Mycelia");
            return rarity = "Mycelia";
        } else if(_tokenId <= remainingRarerTokenIds[0] && _tokenId > startRarerTokenId) {
            emit returnRarityByTokenId(_tokenId, "Obsidian");
            return rarity = "Obsidian";
        } else if(_tokenId <= remainingRarerTokenIds[1] && _tokenId > remainingRarerTokenIds[0]) {
            emit returnRarityByTokenId(_tokenId, "Diamond");
            return rarity = "Diamond";
        } else if(_tokenId <= remainingRarerTokenIds[2] && _tokenId > remainingRarerTokenIds[1]) {
            emit returnRarityByTokenId(_tokenId, "Gold");
            return rarity = "Gold";
        } else if(_tokenId > startRareTokenId) {
            emit returnRarityByTokenId(_tokenId, "Silver");
            return rarity = "Silver";
        }
    }

    /**
    * @dev  Information about the royalty is returned when provided with token Id and sale price 
    * @param _tokenId is the tokenId of an NFT that has been sold on the NFT marketplace
    * @param _salePrice is the price of the sale of the given token Id
    */
    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view override returns (
        address,
        uint256 royaltyAmount
    ) {
        royaltyAmount = (_salePrice / 100) * 10;
        if (_tokenId <= startRarerTokenId) {
            return(addressProductNFTArtist, royaltyAmount);
        } else {
            return(royaltyDistributorAddress, royaltyAmount); 
        }
    }
}
