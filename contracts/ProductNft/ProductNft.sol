//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

//import "./RoyaltyDistributor.sol";
//import "./WhiteListed.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import { IERC2981, IERC165 } from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
@title MembershipNft
@author Marco Huberts & Javier Gonzalez
@dev    Implementation of a Valorize Product Non Fungible Token using ERC721.
*       Key information: have the metadata ordered from token Id 1 to 2012 
*       whereby token Id 1 to 12 are Mycelia, token Id 12 to 1012 Diamond and 
*       token Id 1012 to 2012 Silver.
*       Rarer mint function token Id will start from 12 & Rare mint function token Id will start from 1012.
*       Numbers can change but the token Ids should be in the order mentioned above.
*/

contract ProductNft is ERC1155, IERC2981 {
  using Counters for Counters.Counter;
  string public baseURI;
  Counters.Counter private rarestTokenIds;
  Counters.Counter private rarerTokenIds;
  Counters.Counter private rareTokenIds;
  uint256 public constant PRICE_PER_RAREST_TOKEN = 1.5 ether;
  uint256 public constant PRICE_PER_RARER_TOKEN = 0.55 ether;
  uint256 public constant PRICE_PER_RARE_TOKEN = 0.2 ether;
  uint16 public startRarerTokenIdIndex;
  uint16 public startRareTokenIdIndex;
  address royaltyDistributorAddress;
  address addressProductNFTArtist;
  uint256[] rarerTokenIdsList;

  mapping(uint256 => ProductStatus) public ProductStatusByTokenId;
  mapping(uint => string) public _URIS;

  enum ProductStatus {not_ready, ready, deployed}

  event returnTokenInfo(uint256 tokenIds, string rarity, ProductStatus, string tokenURI);

  constructor( 
    string memory URI_,   
    uint16 _startRarerTokenIdIndex,
    uint16 _startRareTokenIdIndex
    ) ERC1155(URI_) {
        baseURI = URI_;
        startRarerTokenIdIndex = _startRarerTokenIdIndex;
        startRareTokenIdIndex = _startRareTokenIdIndex;
    }

    function _URI(uint256 _tokenId) public view returns (string memory) {
      if(bytes(_URIS[_tokenId]).length != 0) {
        return string(_URIS[_tokenId]);
        }
        return string(abi.encodePacked(baseURI, Strings.toString(_tokenId), ".json"));
    }
    
    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, IERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
    *@dev   This minting function allows the minting of Rarest tokenIds 1 to 12.
    *@param amount: Every call will recursively increment the tokenId 
    *       depending on the amount of tokens the user wants to mint.
    *       These tokenIds are associated with the Mycelia rarity. 
    *       This function can be called for 1.5 ETH.
    */
    function rarestBatchMint(uint256 amount) public payable {
        require(PRICE_PER_RAREST_TOKEN * amount <= msg.value, "Ether value sent is not correct");
        require(amount >= 1, "You need to mint atleast one NFT");
        
        uint256[] memory rarestTokenAmounts = new uint[](amount);
        for (uint256 i = 0; i < amount; i++) {
        rarestTokenAmounts[i] = i + 1;
        }

        uint256[] memory rarestTokenIdsForThisMint = new uint[](rarestTokenAmounts.length); 
        for (uint256 i = 0; i < rarestTokenAmounts.length; i++) { 
            rarestTokenIds.increment();
            uint256 newRarestTokenId = rarestTokenIds.current();
            require(newRarestTokenId <= startRarerTokenIdIndex, "Mycelia NFTs are sold out");
            rarestTokenIdsForThisMint[i] = newRarestTokenId;
            ProductStatusByTokenId[newRarestTokenId] = ProductStatus.ready;
            _URIS[newRarestTokenId] = _URI(newRarestTokenId);
            emit returnTokenInfo(newRarestTokenId, "Mycelia", ProductStatusByTokenId[newRarestTokenId], _URIS[newRarestTokenId]);
        }
        _mintBatch(msg.sender, rarestTokenIdsForThisMint, rarestTokenAmounts, '');
    }

    /**
    *@dev   This minting function allows the minting of Rarest tokenIds 12 to 1012.
    *@param amount: Every call will recursively increment the tokenId 
    *       depending on the amount of tokens the user wants to mint.
    *       These tokenIds are associated with the Diamond rarity. 
    *       This function can be called for 0.55 ETH.
    */
    function rarerBatchMint(uint256 amount) public payable {
        require(PRICE_PER_RARER_TOKEN * amount <= msg.value, "Ether value sent is not correct");
        require(amount >= 1, "You need to mint atleast one NFT");

        uint256[] memory rarerTokenAmountsForThisMint = new uint[](amount);
        for (uint256 i = 0; i < amount; i++) {
            rarerTokenAmountsForThisMint[i] = i + 1;
        }

        uint256[] memory rarerTokenIdsForThisMint = new uint[](rarerTokenAmountsForThisMint.length); 
        for (uint256 i = 0; i < rarerTokenAmountsForThisMint.length; i++) { 
            rarerTokenIds.increment();
            uint256 newRarerTokenId = startRarerTokenIdIndex + rarerTokenIds.current();
            require(newRarerTokenId >= startRarerTokenIdIndex && newRarerTokenId <= startRareTokenIdIndex, "Diamond NFTS are sold out");
            rarerTokenIdsForThisMint[i] = newRarerTokenId;
            rarerTokenIdsList.push(newRarerTokenId);
            ProductStatusByTokenId[newRarerTokenId] = ProductStatus.not_ready;
            _URIS[newRarerTokenId] = _URI(newRarerTokenId);
            emit returnTokenInfo(newRarerTokenId, "Diamond", ProductStatusByTokenId[newRarerTokenId], _URI(newRarerTokenId));
        }
        _mintBatch(msg.sender, rarerTokenIdsForThisMint, rarerTokenAmountsForThisMint, '');
    }

    /**
    *@dev   This minting function allows the minting of Rarest tokenIds 1012 to 2012.
    *@param amount: Every call will recursively increment the tokenId 
    *       depending on the amount of tokens the user wants to mint.
    *       These tokenIds are associated with the Silver rarity. 
    *       This function can be called for 0.2 ETH.
    */
    function rareBatchMint(uint256 amount) public payable {
        require(PRICE_PER_RARE_TOKEN * amount <= msg.value, "Ether value sent is not correct");
        require(amount >= 1, "You need to mint atleast one NFT");
        
        uint256[] memory rareTokenAmountsForThisMint = new uint[](amount);
        for (uint256 i = 0; i < amount; i++) {
            rareTokenAmountsForThisMint[i] = i + 1;
        }

        uint256[] memory rareTokenIdsForThisMint = new uint[](rareTokenAmountsForThisMint.length); 
        for (uint256 i = 0; i < rareTokenAmountsForThisMint.length; i++) { 
            rareTokenIds.increment();
            uint256 newRareTokenId = startRareTokenIdIndex + rareTokenIds.current();
            require(newRareTokenId <= 2012, "Silver NFTs are sold out");
            rareTokenIdsForThisMint[i] = newRareTokenId;
            ProductStatusByTokenId[newRareTokenId] = ProductStatus.ready;
            emit returnTokenInfo(newRareTokenId, "Silver", ProductStatusByTokenId[newRareTokenId], _URI(newRareTokenId)); 
        }
        _mintBatch(msg.sender, rareTokenIdsForThisMint, rareTokenAmountsForThisMint, '');
    }

    /**
    *@dev   This function will switch the status of product deployment to deployed.
    *       Information regarding deployment should be retrieved with an API
    *@param tokenId: the token Id of the NFT that is used to deploy a (free) token
    *       using the Valorize Token Launcher
    *@param deployed: set to true if a token has been deployed 
    */

    function switchProductStatusAfterTokenLaunch(uint256 tokenId, bool deployed) public {
        if (deployed == true) {
            ProductStatusByTokenId[tokenId] = ProductStatus.deployed;
        }
    }

    function switchProductStatusAfterTimePassed(uint256 timeStampForDeployment) public {
        require(block.timestamp > timeStampForDeployment);
        for(uint256 i=0; i < rarerTokenIdsList.length; i++) {
            require(rarerTokenIdsList[i] > startRarerTokenIdIndex && rarerTokenIdsList[i] < startRareTokenIdIndex);
            ProductStatusByTokenId[rarerTokenIdsList[i]] = ProductStatus.ready;
        }
    }

    /**
    * @dev  This function returns the token information 
    *       This includes token id, rarity, product status and URI
    * @param _tokenId is the token Id of the NFT of interest
    */
    function getTokenInfo(uint256 _tokenId) external returns(string memory rarity) {
        if(_tokenId < startRarerTokenIdIndex) {
            emit returnTokenInfo(_tokenId, "Mycelia", ProductStatusByTokenId[_tokenId], _URIS[_tokenId]);
            return rarity = "Mycelia";
        } else if(_tokenId <= startRareTokenIdIndex && _tokenId > startRarerTokenIdIndex) {
            emit returnTokenInfo(_tokenId, "Diamond", ProductStatusByTokenId[_tokenId], _URIS[_tokenId]);
            return rarity = "Diamond";
        } else if(_tokenId > startRareTokenIdIndex) {
            emit returnTokenInfo(_tokenId, "Silver", ProductStatusByTokenId[_tokenId], _URIS[_tokenId]);
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
        if (_tokenId <= startRarerTokenIdIndex) {
            return(addressProductNFTArtist, royaltyAmount);
        } else {
            return(royaltyDistributorAddress, royaltyAmount); 
        }
    }
}
