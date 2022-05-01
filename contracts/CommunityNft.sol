//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
@title CommunityNft
@author Marco Huberts & Javier Gonzalez
@dev Implementation of a Community Non Fungible Token using ERC721B.
*/

contract CommunityNft is ERC721, Ownable {
  using Strings for uint256;

  bool public REVEAL = false;
  bool public isWhaleAllowListActive = false;
  bool public isSealAllowListActive = false;
  bool public isPlanktonAllowListActive = false;
  uint256 public constant PRICE_PER_WHALE_TOKEN = 1.0 ether;
  uint256 public constant PRICE_PER_SEAL_TOKEN = 0.2 ether;
  uint256 public constant PRICE_PER_PLANKTON_TOKEN = 0.1 ether;
  string public URI;

  mapping(address => uint8) private _whaleAllowList;
  mapping(address => uint8) private _sealAllowList;
  mapping(address => uint8) private _planktonAllowList;
  
  mapping(uint => string) private _URIS;

  uint256 public whaleTokensLeft = 50;
  uint256 public sealTokensLeft = 150;
  uint256 public planktonTokensLeft = 2800;

  uint256 public whaleMyceliaId = 1;
  uint256 public whaleObsidianId = 4;
  uint256 public whaleDiamondId = 19;

  uint256 public sealMyceliaId = 51;
  uint256 public sealObsidianId = 54;
  uint256 public sealDiamondId = 69;
  uint256 public sealGoldId = 126;

  uint256 public planktonMyceliaId = 201;
  uint256 public planktonObsidianId = 204;
  uint256 public planktonDiamondId = 224;
  uint256 public planktonGoldId = 376;
  uint256 public planktonSilverId = 1301;

  constructor(
    string memory name, 
    string memory symbol, 
    string memory initialURI
  ) ERC721(name, symbol) {
    URI = initialURI;
  }
//random idea: making one extra Mycelia NFT unmintable for 10 years (token ID = 0) create a bid system for it. In those 10 years we can build out our product to something incredibly valuable
// then give every service for free for the one that buys this NFT.

  // function tokenURI(uint256 tokenId) public view override returns (string memory) {
  //     if (REVEAL) {
  //         return string(abi.encodePacked(URI, tokenId.toString()));
  //     }
  //     return URI;
  // }

  function _safeMint(address to, uint256 tokenId) override internal virtual {
        _safeMint(to, tokenId, "");
   }

  function getRandomWhaleNFT() public payable {
    uint256 whaleTokenId = (block.number / whaleTokensLeft) % whaleTokensLeft + 1; 
    whaleTokensLeft--;
    require(PRICE_PER_WHALE_TOKEN == msg.value, "Ether value sent is not correct");

    if (whaleTokenId <= 3 && whaleMyceliaId <=3) {
      whaleMint(msg.sender, whaleMyceliaId, ''); 
      whaleMyceliaId++;
    } else if (whaleTokenId <= 18 && whaleObsidianId <=18) {
      whaleMint(msg.sender, whaleObsidianId, ''); 
      whaleObsidianId++;
    } else if (whaleTokenId <= 50 && whaleDiamondId <=50) {
      whaleMint(msg.sender, whaleDiamondId, ''); 
      whaleDiamondId++;
    }
  }

  function getRandomSealNFT() public payable {
    uint256 sealTokenId = 50 + ((block.number / sealTokensLeft) % sealTokensLeft + 1);
    sealTokensLeft--;
    require(PRICE_PER_SEAL_TOKEN == msg.value, "Ether value sent is not correct");

    if (sealTokenId <= 53 && sealMyceliaId <= 53) {
      sealMint(msg.sender, sealMyceliaId, ''); 
      sealMyceliaId++;
    } else if (sealTokenId <= 68 && sealObsidianId <= 68) {
      sealMint(msg.sender, sealObsidianId, '');
      sealObsidianId++;
    } else if (sealTokenId <= 125 && sealDiamondId <= 125) {
      sealMint(msg.sender, sealDiamondId, ''); 
      sealDiamondId++;
    } else if (sealTokenId <= 200 && sealGoldId <= 200) {
      sealMint(msg.sender, sealGoldId, ''); 
      sealGoldId++;
    }
  }

  function getRandomPlanktonNFT() public payable {
    uint256 planktonTokenId = 200 + ((block.number / planktonTokensLeft) % planktonTokensLeft + 1);
    planktonTokensLeft--; 
    require(PRICE_PER_PLANKTON_TOKEN == msg.value, "Ether value sent is not correct");

    if (planktonTokenId <= 203 && planktonMyceliaId <= 203) {
      planktonMint(msg.sender, planktonMyceliaId, '');
      planktonMyceliaId++;
    } else if (planktonTokenId <= 223 && planktonObsidianId <= 223) {
      planktonMint(msg.sender, planktonObsidianId, ''); 
      planktonObsidianId++;
    } else if (planktonTokenId <= 375  && planktonDiamondId <= 375) {
      planktonMint(msg.sender, planktonDiamondId, '');
      planktonDiamondId++;
    } else if (planktonTokenId <= 1300 && planktonGoldId <= 1300) {
      planktonMint(msg.sender, planktonGoldId, ''); 
      planktonGoldId++;
    } else if (planktonTokenId <= 3000 && planktonSilverId <= 3000) {
      planktonMint(msg.sender, planktonSilverId, ''); 
      planktonSilverId++;
    }
  }

  function whaleMint(address recipient, uint256 whaleTokenId, bytes memory data) public payable {
    require(whaleTokenId >= 1 && whaleTokenId <= 50, "the whale NFTs are sold out");
    _safeMint(recipient, whaleTokenId, data);
  }

  function sealMint(address recipient, uint256 sealTokenId, bytes memory data) public payable {
    require(sealTokenId >= 51 && sealTokenId <= 200, "the seal NFTs are sold out");
    _safeMint(recipient, sealTokenId, data);
  }

  function planktonMint(address recipient, uint256 planktonTokenId, bytes memory data) public payable {
    require(planktonTokenId >= 201 && planktonTokenId <= 3000, "the plankton NFTs are sold out");
    _safeMint(recipient, planktonTokenId, data);
  }

  function toggleReveal(string memory updatedURI) public onlyOwner {
    REVEAL = !REVEAL;
    URI = updatedURI;
  }

  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    if (REVEAL) {
      if(bytes(_URIS[tokenId]).length != 0) {
        return string(_URIS[tokenId]);
    }
      return string(abi.encodePacked(URI, tokenId.toString()));
    }
    return URI;
  }

  function setIsWhaleAllowListActive(bool _isWhaleAllowListActive) external onlyOwner {
      isWhaleAllowListActive = _isWhaleAllowListActive;
  }

  function setIsSealAllowListActive(bool _isSealAllowListActive) external onlyOwner {
      isSealAllowListActive = _isSealAllowListActive;
  }

  function setIsPlanktonAllowListActive(bool _isPlanktonAllowListActive) external onlyOwner {
      isPlanktonAllowListActive = _isPlanktonAllowListActive;
  }

  function numAvailableToWhaleMint(address addr) external view returns (uint8) {
        return _whaleAllowList[addr];
  }

function numAvailableToSealMint(address addr) external view returns (uint8) {
        return _sealAllowList[addr];
  }

function numAvailableToPlanktonMint(address addr) external view returns (uint8) {
        return _planktonAllowList[addr];
  }

  function setWhaleAllowList(address[] calldata addresses, uint8 numAllowedToMint) external onlyOwner {
    for (uint256 i = 0; i < addresses.length; i++) {
          _whaleAllowList[addresses[i]] = numAllowedToMint;
    }//how many addresses for whitelist? my suggestion: a total of 45 and people can choose themselves which list they come on
  } //if no preference is given then by default plankton whitelist? 
    
  function setSealAllowList(address[] calldata addresses, uint8 numAllowedToMint) external onlyOwner {
    for (uint256 i = 0; i < addresses.length; i++) {
          _sealAllowList[addresses[i]] = numAllowedToMint;
    }
  } 

  function setPlanktonAllowList(address[] calldata addresses, uint8 numAllowedToMint) external onlyOwner {
    for (uint256 i = 0; i < addresses.length; i++) {
          _planktonAllowList[addresses[i]] = numAllowedToMint;
    }
  } 

  function whaleMintAllowList(uint8 numberOfTokens) external payable {
      require(isWhaleAllowListActive, "Allow list is not active");
      require(numberOfTokens <= _whaleAllowList[msg.sender], "Exceeded max available to purchase");
      require(PRICE_PER_WHALE_TOKEN * numberOfTokens <= msg.value, "Ether value sent is not correct");

      _whaleAllowList[msg.sender] -= numberOfTokens;
      for (uint256 i = 0; i < numberOfTokens; i++) {
          getRandomWhaleNFT();
    }
  }

  function sealMintAllowList(uint8 numberOfTokens) external payable {
      require(isSealAllowListActive, "Allow list is not active");
      require(numberOfTokens <= _sealAllowList[msg.sender], "Exceeded max available to purchase");
      require(PRICE_PER_SEAL_TOKEN * numberOfTokens <= msg.value, "Ether value sent is not correct");

      _sealAllowList[msg.sender] -= numberOfTokens;
      for (uint256 i = 0; i < numberOfTokens; i++) {
          getRandomSealNFT();
    }
  }

  function planktonMintAllowList(uint8 numberOfTokens) external payable {
      require(isPlanktonAllowListActive, "Allow list is not active");
      require(numberOfTokens <= _planktonAllowList[msg.sender], "Exceeded max available to purchase");
      require(PRICE_PER_PLANKTON_TOKEN * numberOfTokens <= msg.value, "Ether value sent is not correct");

      _planktonAllowList[msg.sender] -= numberOfTokens;
      for (uint256 i = 0; i < numberOfTokens; i++) {
          getRandomPlanktonNFT();
    }
  }
}