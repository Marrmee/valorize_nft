//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
//import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
@title NonFungibleToken
@author Marco Huberts & Javier Gonzalez
@dev Implementation of a Non Fungible Token.

Content layout:
**Tiered PFP**
**Tiers of Rarity**
10 Dead Star Material
20 Platinum
50 Diamonds
500 Gold
1000 Silver total of 1580 NFTs
*/

contract NonFungibleToken is ERC1155 {
    using Counters for Counters.Counter;
    Counters.Counter private whaleTokenIds;
    Counters.Counter private sealTokenIds;
    Counters.Counter private shrimpTokenIds;
    uint256[] _newWhaleTokenIds;
    string[] _newWhaleTokenURIs;
    uint256[] _newSealTokenIds;
    string[] _newSealTokenURIs;
    uint256[] _newShrimpTokenIds;
    string[] _newShrimpTokenURIs;

  mapping(uint => string) private _URIS;

  constructor(string memory uri) ERC1155(uri) {}

  event MintCompleted(address to, uint256[] tokenId, uint256[] _amountMinted);
  event ReturnURIandID(uint256[] tokenId, string[] tokenURIs);

  function whaleBatchMint(
    address _recipient,
    uint256[] memory _amounts,
    bytes memory data)
    public payable {
    //_amounts = _newWhaleTokenIds.push(_newAmounts);
    for (uint256 i = 0; i < _newWhaleTokenIds.length; i++) {
      _amounts.push(_newWhaleTokenIds[i]);
    }
    require(_recipient == msg.sender);
    require(_amounts.length > 0, "You need to mint atleast one NFT");
    for (uint256 i = 0; i < _amounts.length; i++) {
      _newWhaleTokenIds.push(_amounts[i]);
      require(_amounts[i] == 0, "Your NFT will not be unique");
      whaleTokenIds.increment();
      uint256 _newWhaleTokenId = whaleTokenIds.current();
      require(_newWhaleTokenId >= 1 && _newWhaleTokenId <= 50, "Diamond, Platinum and Obsidian NFTs are sold out");
      _newWhaleTokenURIs.push(uri(_newWhaleTokenId));
      _newWhaleTokenIds.push(_newWhaleTokenId);
    }
    _mintBatch(_recipient, _newWhaleTokenIds, _amounts, data);
    emit MintCompleted(msg.sender, _newWhaleTokenIds, _amounts);
    emit ReturnURIandID(_newWhaleTokenIds, _newWhaleTokenURIs);
  }

  function sealBatchMint(
    address _recipient,
    uint256[] memory _amounts,
    bytes memory data)
    public payable returns (uint256 _newSealTokenId) {
    require(_amounts.length > 0, "You need to mint atleast one NFT");
    for (uint256 i = 0; i < _amounts.length; i++) {
      sealTokenIds.increment();
      _newSealTokenId = sealTokenIds.current();
      require(_newSealTokenId >= 1 && _newSealTokenId <= 300, "Gold NFTS are sold out");
      uri(_newSealTokenId);
      _newSealTokenIds.push(_newSealTokenId);
    }
    _mintBatch(_recipient, _newSealTokenIds, _amounts, data);
    emit MintCompleted(msg.sender, _newSealTokenIds, _amounts);
  }

  function shrimpBatchMint(
    address _recipient,
    uint256[] memory _amounts,
    bytes memory data)
    public payable returns (uint256 _newShrimpTokenId) {
    require(_amounts.length > 0, "You need to mint atleast one NFT");
    for (uint256 i = 0; i < _amounts.length; i++) {
      shrimpTokenIds.increment();
      _newShrimpTokenId = shrimpTokenIds.current();
      require(_newShrimpTokenId >= 1 && _newShrimpTokenId <= 1000, "Silver NFTs are sold out");
      uri(_newShrimpTokenId);
      _newShrimpTokenIds.push(_newShrimpTokenId);
    }
    _mintBatch(_recipient, _newShrimpTokenIds, _amounts, data);
    emit MintCompleted(msg.sender, _newShrimpTokenIds, _amounts);
  }

  /**
  3 to 1 conversion?
  */

  function SealtoWhaleConversion(
    address _nftOwner,
    uint256[] memory _tokenIds,
    uint256[] memory _amountsForBurning,
    uint256[] memory _oneWhaleToken,
    bytes memory data)
    external payable {
    require(_nftOwner == msg.sender, "you are not the owner of the NFTs");
    require(_oneWhaleToken.length == 1);
    require(_amountsForBurning.length > 3);
    _burnBatch(msg.sender, _tokenIds, _amountsForBurning);
    whaleBatchMint(msg.sender, _oneWhaleToken, data);
    emit MintCompleted(msg.sender, _newWhaleTokenIds, _oneWhaleToken);
  }

  function ShrimptoSealConversion(
    address _nftOwner,
    uint256[] memory _tokenIds,
    uint256[] memory _amountsForBurning,
    uint256[] memory _oneSealToken,
    bytes memory data)
    external payable {
    require(_nftOwner == msg.sender, "you are not the owner of the NFTs");
    require(_oneSealToken.length == 1);
    require(_amountsForBurning.length > 3);
    _burnBatch(msg.sender, _tokenIds, _amountsForBurning);
    whaleBatchMint(msg.sender, _oneSealToken, data);
    emit MintCompleted(msg.sender, _newSealTokenIds, _oneSealToken);
  }

  function uri(uint256 _tokenId) override public view returns (string memory) {
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
}
