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

contract ProductNft is ERC1155, IERC2981 {
  using Counters for Counters.Counter;
  Counters.Counter private rarestTokenIds;
  Counters.Counter private rarerTokenIds;
  Counters.Counter private rareTokenIds;
  uint256 public _newRarestTokenId;
  uint256 public _newRarerTokenId;
  uint256 public _newRareTokenId;
  string[] _newRarestTokenURIs;
  string[] _newRarerTokenURIs;
  string[] _newRareTokenURIs;
  uint256 public constant PRICE_PER_RAREST_TOKEN = 1.5 ether;
  uint256 public constant PRICE_PER_RARER_TOKEN = 0.55 ether;
  uint256 public constant PRICE_PER_RARE_TOKEN = 0.2 ether;
  uint16 public startRarerTokenIdIndex;
  uint16 public startRareTokenIdIndex;
  address royaltyDistributorAddress;
  address addressProductNFTArtist;
  uint256[] rarerTokenIdsList; 
  //ProductStatus public productStatus;  

  mapping(uint256 => ProductStatus) public ProductStatusByTokenId;
  mapping(uint256 => bool) public TokenDeploymentStatus; 
  mapping(uint => string) private _URIS;

  enum ProductStatus {not_ready, ready, deployed}

  event returnRarityByTokenIdAndProductLaunchingStatus(uint256 tokenIds, string rarity, ProductStatus);
  event MintCompleted(address to, uint256[] tokenId, uint256[] _amountMinted);
  event ReturnURIandID(uint256[] tokenIds, string[] tokenURIs);

  constructor( 
    string memory _URI,   
    uint16 _startRarerTokenIdIndex,
    uint16 _startRareTokenIdIndex
    ) ERC1155(_URI) {
        startRarerTokenIdIndex = _startRarerTokenIdIndex;
        startRareTokenIdIndex = _startRareTokenIdIndex;
    }

    function uri_(uint256 _tokenId) public view returns (string memory) {
      if(bytes(_URIS[_tokenId]).length != 0) {
        return string(_URIS[_tokenId]);
        }
        return string(
            abi.encodePacked(
            "https://baseURI/",//needs to be changed to actual baseURI
            Strings.toString(_tokenId),
            ".json")
        );
    }
    
    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, IERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
    * @dev  This minting function allows the minting of Rarest tokenIds 10 to 1.
    *       These tokenIds are associated with the Mycelia rarity.
    *       Every call will decrement the tokenId (starting from 10). 
    *       This function can be called for 1.5 ETH.
    */


    /**
    * @dev  This minting function allows the minting of Rarer token Ids 10 to 1010.
    *       It can be called for 0.55 ETH.
    */


    /**
    * @dev  This minting function allows the minting of Rare tokenIds 1010 to 2010.
    *       These tokenIds are associated with the Mycelia rarity.
    *       Every call will decrement the tokenId (starting from token Id 2010). 
    *       This function can be called for 0.2 ETH.
    */


    function rarestBatchMint(
        uint256[] memory _amounts)
        public payable {
        require(PRICE_PER_RAREST_TOKEN * _amounts.length <= msg.value, "Ether value sent is not correct");
        uint256[] memory rarestTokenAmounts = new uint[](_amounts[0]);
        for (uint256 i = 0; i < _amounts[0]; i++) {
        rarestTokenAmounts[i] = i + 1;
        }

        require(_amounts[0] >= 1, "You need to mint atleast one NFT");
        uint256[] memory _newRarestTokenIdsForThisMint = new uint[](rarestTokenAmounts.length); 
        for (uint256 i = 0; i < rarestTokenAmounts.length; i++) { 
            rarestTokenIds.increment();
            _newRarestTokenId = rarestTokenIds.current();
            require(_newRarestTokenId >= 1 && _newRarestTokenId <= startRarerTokenIdIndex, "Mycelia NFTs are sold out");
            _newRarestTokenIdsForThisMint[i] = _newRarestTokenId;
            ProductStatusByTokenId[_newRarestTokenId] = ProductStatus.ready;
            emit returnRarityByTokenIdAndProductLaunchingStatus(_newRarestTokenId, "Mycelia", ProductStatusByTokenId[_newRarestTokenId]);
        }
        _mintBatch(msg.sender, _newRarestTokenIdsForThisMint, rarestTokenAmounts, '');

        emit MintCompleted(msg.sender, _newRarestTokenIdsForThisMint, rarestTokenAmounts);
        emit ReturnURIandID(_newRarestTokenIdsForThisMint, _newRarestTokenURIs);
    }

    function rarerBatchMint(
        uint256[] memory _amounts)
        public payable {
        require(PRICE_PER_RARER_TOKEN * _amounts.length <= msg.value, "Ether value sent is not correct");
        uint256[] memory rarerTokenAmountsForThisMint = new uint[](_amounts[0]);
        for (uint256 i = 0; i < _amounts[0]; i++) {
            rarerTokenAmountsForThisMint[i] = i + 1;
        }
        require(_amounts[0] >= 1, "You need to mint atleast one NFT");
        uint256[] memory _newRarerTokenIdsForThisMint = new uint[](rarerTokenAmountsForThisMint.length); 
        for (uint256 i = 0; i < rarerTokenAmountsForThisMint.length; i++) { 
            rarerTokenIds.increment();
            _newRarerTokenId = startRarerTokenIdIndex + rarerTokenIds.current();
            require(_newRarerTokenId >= startRarerTokenIdIndex && _newRarerTokenId <= startRareTokenIdIndex, "Diamond NFTS are sold out");
            _newRarerTokenIdsForThisMint[i] = _newRarerTokenId;
            rarerTokenIdsList.push(_newRarerTokenId);
            ProductStatusByTokenId[_newRarerTokenId] = ProductStatus.not_ready;
            emit returnRarityByTokenIdAndProductLaunchingStatus(_newRarerTokenId, "Diamond", ProductStatusByTokenId[_newRarerTokenId]);
        }
        _mintBatch(msg.sender, _newRarerTokenIdsForThisMint, rarerTokenAmountsForThisMint, '');
        emit MintCompleted(msg.sender, _newRarerTokenIdsForThisMint, rarerTokenAmountsForThisMint);
        emit ReturnURIandID(_newRarerTokenIdsForThisMint, _newRarestTokenURIs);
    }

    function rareBatchMint(
        uint256[] memory _amounts)
        public payable {
        require(PRICE_PER_RARE_TOKEN * _amounts.length <= msg.value, "Ether value sent is not correct");
        uint256[] memory rareTokenAmounts = new uint[](_amounts[0]);
        for (uint256 i = 0; i < _amounts[0]; i++) {
            rareTokenAmounts[i] = i + 1;
        }
        require(_amounts[0] >= 1, "You need to mint atleast one NFT");
        uint256[] memory _newRareTokenIdsForThisMint = new uint[](rareTokenAmounts.length); 
        for (uint256 i = 0; i < rareTokenAmounts.length; i++) { 
            rareTokenIds.increment();
            _newRareTokenId = startRareTokenIdIndex + rareTokenIds.current();
            require(_newRareTokenId >= startRareTokenIdIndex && _newRareTokenId <= 2012, "Silver NFTs are sold out");
            _newRareTokenIdsForThisMint[i] = _newRareTokenId;
            ProductStatusByTokenId[_newRareTokenId] = ProductStatus.ready;
            emit returnRarityByTokenIdAndProductLaunchingStatus(_newRareTokenId, "Silver", ProductStatusByTokenId[_newRareTokenId]); 
        }
        _mintBatch(msg.sender, _newRareTokenIdsForThisMint, rareTokenAmounts, '');
        emit MintCompleted(msg.sender, _newRareTokenIdsForThisMint, rareTokenAmounts);
        emit ReturnURIandID(_newRareTokenIdsForThisMint, _newRarestTokenURIs);
    }

    function switchProductStatusAfterTokenLaunch(uint256 tokenId, bool deployed) public {
        if (deployed == true) {
            TokenDeploymentStatus[tokenId] = deployed;
            ProductStatusByTokenId[tokenId] = ProductStatus.deployed;//how does the picture change then?
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
    * @dev  rarity of a token Id is returned using an event
    * @param _tokenId is the token Id of the NFT of interest
    */
    function getRarityAndDeploymentStageByTokenId(uint256 _tokenId) external returns(string memory rarity) {
        if(_tokenId < startRarerTokenIdIndex) {
            emit returnRarityByTokenIdAndProductLaunchingStatus(_tokenId, "Mycelia", ProductStatusByTokenId[_tokenId]);
            return rarity = "Mycelia";
        } else if(_tokenId <= startRareTokenIdIndex && _tokenId > startRarerTokenIdIndex) {
            emit returnRarityByTokenIdAndProductLaunchingStatus(_tokenId, "Diamond", ProductStatusByTokenId[_tokenId]);
            return rarity = "Diamond";
        } else if(_tokenId > startRareTokenIdIndex) {
            emit returnRarityByTokenIdAndProductLaunchingStatus(_tokenId, "Silver", ProductStatusByTokenId[_tokenId]);
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
