//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.14;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
@title CommunityNft
@author Marco Huberts & Javier Gonzalez
@dev Implementation of a Community Non Fungible Token using ERC1155.
*/

contract CommunityNFT is ERC1155 {
  using Counters for Counters.Counter;
  Counters.Counter private whaleTokenIds;
  Counters.Counter private sealTokenIds;
  Counters.Counter private planktonTokenIds;
  uint256 public _newWhaleTokenId;
  uint256 public _newSealTokenId;
  uint256 public _newPlanktonTokenId;
  string[] _newWhaleTokenURIs;
  string[] _newSealTokenURIs;
  string[] _newShrimpTokenURIs;

  mapping(uint => string) private _URIS;

  constructor(string memory uri_) ERC1155(uri_) {}

  event MintCompleted(address to, uint256[] tokenId, uint256[] _amountMinted);
  event ReturnURIandID(uint256[] tokenIds, string[] tokenURIs);

  function whaleBatchMint(
    address _recipient,
    uint256[] memory _amounts)
    public payable {

    uint256[] memory whaleTokenAmounts = new uint[](_amounts[0]);
    for (uint256 i = 0; i < _amounts[0]; i++) {
      whaleTokenAmounts[i] = i + 1;
    }

    require(_amounts[0] >= 1, "You need to mint atleast one NFT");
    uint256[] memory _newWhaleTokenIds = new uint[](whaleTokenAmounts.length); 
    for (uint256 i = 0; i < whaleTokenAmounts.length; i++) { 
      whaleTokenIds.increment();
      _newWhaleTokenId = whaleTokenIds.current();
      require(_newWhaleTokenId >= 1 && _newWhaleTokenId <= 50, "Diamond, Platinum and Obsidian NFTs are sold out");
      _newWhaleTokenIds[i] = _newWhaleTokenId;
    }
    _mintBatch(_recipient, _newWhaleTokenIds, whaleTokenAmounts, '');
    emit MintCompleted(msg.sender, _newWhaleTokenIds, whaleTokenAmounts);
    emit ReturnURIandID(_newWhaleTokenIds, _newWhaleTokenURIs);
  }

  function sealBatchMint(
    address _recipient,
    uint256[] memory _amounts,
    bytes memory data)
    public payable {

    uint256[] memory sealTokenAmounts = new uint[](_amounts[0]);
    for (uint256 i = 0; i < _amounts[0]; i++) {
      sealTokenAmounts[i] = i + 1;
    }
    //require(_recipient == msg.sender, "you can only mint to your connected address"); 
    require(_amounts[0] >= 1, "You need to mint atleast one NFT");
    uint256[] memory _newSealTokenIds = new uint[](sealTokenAmounts.length); 
    for (uint256 i = 0; i < sealTokenAmounts.length; i++) { 
      sealTokenIds.increment();
      _newSealTokenId = sealTokenIds.current();
      require(_newSealTokenId >= 1 && _newSealTokenId <= 300, "Gold NFTS are sold out");
      _newSealTokenIds[i] = _newSealTokenId;
    }
    _mintBatch(_recipient, _newSealTokenIds, sealTokenAmounts, data);
    emit MintCompleted(msg.sender, _newSealTokenIds, sealTokenAmounts);
    emit ReturnURIandID(_newSealTokenIds, _newWhaleTokenURIs);
  }

  function planktonBatchMint(
    address _recipient,
    uint256[] memory _amounts,
    bytes memory data)
    public payable {

    uint256[] memory planktonTokenAmounts = new uint[](_amounts[0]);
    for (uint256 i = 0; i < _amounts[0]; i++) {
      planktonTokenAmounts[i] = i + 1;
    }
    //require(_recipient == msg.sender, "you can only mint to your connected address"); 
    require(_amounts[0] >= 1, "You need to mint atleast one NFT");
    uint256[] memory _newPlanktonTokenIds = new uint[](planktonTokenAmounts.length); 
    for (uint256 i = 0; i < planktonTokenAmounts.length; i++) { 
      planktonTokenIds.increment();
      _newPlanktonTokenId = planktonTokenIds.current();
      require(_newPlanktonTokenId >= 1 && _newPlanktonTokenId <= 1000, "Silver NFTs are sold out");
      _newPlanktonTokenIds[i] = _newPlanktonTokenId;
    }
    _mintBatch(_recipient, _newPlanktonTokenIds, planktonTokenAmounts, data);
    emit MintCompleted(msg.sender, _newPlanktonTokenIds, planktonTokenAmounts);
    emit ReturnURIandID(_newPlanktonTokenIds, _newWhaleTokenURIs);
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
}
