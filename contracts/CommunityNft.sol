//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
@title CommunityNft
@author Marco Huberts & Javier Gonzalez
@dev Implementation of a Community Non Fungible Token using ERC721B.
*/

//https://dev.to/lilcoderman/create-a-whitelist-for-your-nft-project-1g55

contract CommunityNft is ERC721, Ownable {

  bool public isWhaleAllowListActive = false;
  bool public isSealAllowListActive = false;
  bool public isPlanktonAllowListActive = false;
  uint256 public constant PRICE_PER_WHALE_TOKEN = 1.0 ether;
  uint256 public constant PRICE_PER_SEAL_TOKEN = 0.2 ether;
  uint256 public constant PRICE_PER_PLANKTON_TOKEN = 0.1 ether;
  string public URI;

  mapping(address => bool) private _whaleAllowList;
  mapping(address => bool) private _sealAllowList;
  mapping(address => bool) private _planktonAllowList;


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
//random idea: making one extra Mycelia NFT unmintable for 10 years (token ID = 0) create a bid system for it 
//==> lock up ether unless bid is higher. Long term vision Valorize DAO
//In those 10 years we can build out our product to something incredibly valuable
//then give every service for free for the one that buys this NFT.
//whitelist number
//limit per msg.sender/ip address (governor DAO sybil resistance)?
//

  function _safeMint(address to, uint256 tokenId) override internal virtual {
        _safeMint(to, tokenId, "");
  }

  function mintRandomWhaleNFT() public payable {
    uint256 i = uint256(uint160(address(msg.sender)));
    uint256 whaleTokenId = (block.difficulty + i / whaleTokensLeft) % whaleTokensLeft + 1; 
    whaleTokensLeft--;
    require(PRICE_PER_WHALE_TOKEN == msg.value, "Ether value sent is not correct");

    if (whaleTokenId <= 3 && whaleMyceliaId <=3) { //remainingWhaleMycelia > 0)
      whaleMint(msg.sender, whaleMyceliaId, ''); 
      whaleMyceliaId++; //remainingWhaleMycelia--; 
    } else if (whaleTokenId <= 18 && whaleObsidianId <=18) {
      whaleMint(msg.sender, whaleObsidianId, ''); 
      whaleObsidianId++;
    } else if (whaleTokenId <= 50 && whaleDiamondId <=50) {
      whaleMint(msg.sender, whaleDiamondId, ''); 
      whaleDiamondId++;
    }
  }

  function mintRandomSealNFT() public payable {
    uint256 i = uint256(uint160(address(msg.sender)));
    uint256 sealTokenId = 50 + ((block.difficulty + i / sealTokensLeft) % sealTokensLeft + 1);
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
//whitelist number
//limit per msg.sender/ip address (governor DAO sybil resistance)?
//
  function mintRandomPlanktonNFT() public payable {
    uint256 i = uint256(uint160(address(msg.sender)));
    uint256 planktonTokenId = 200 + ((block.difficulty + i / planktonTokensLeft) % planktonTokensLeft + 1);
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

  function whaleMint(address recipient, uint256 whaleTokenId, bytes memory data) internal {
    require(whaleTokenId >= 1 && whaleTokenId <= 50, "the whale NFTs are sold out");
    _safeMint(recipient, whaleTokenId, data);
  }

  function sealMint(address recipient, uint256 sealTokenId, bytes memory data) internal {
    require(sealTokenId >= 51 && sealTokenId <= 200, "the seal NFTs are sold out");
    _safeMint(recipient, sealTokenId, data);
  }

  function planktonMint(address recipient, uint256 planktonTokenId, bytes memory data) internal {
    require(planktonTokenId >= 201 && planktonTokenId <= 3000, "the plankton NFTs are sold out");
    _safeMint(recipient, planktonTokenId, data);
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

  function numAvailableToWhaleMint(address addr) external view returns (bool) {
        return _whaleAllowList[addr];
  }

function numAvailableToSealMint(address addr) external view returns (bool) {
        return _sealAllowList[addr];
  }

function numAvailableToPlanktonMint(address addr) external view returns (bool) {
        return _planktonAllowList[addr];
  }

  function setWhaleAllowList(address[] calldata addresses) external onlyOwner {
    for (uint256 i = 0; i < addresses.length; i++) {
          _whaleAllowList[addresses[i]] = true;
    }//how many addresses for whitelist? my suggestion: a total of 45 and people can choose themselves which list they come on
  } //if no preference is given then by default plankton whitelist? 
    
  function setSealAllowList(address[] calldata addresses) external onlyOwner {
    for (uint256 i = 0; i < addresses.length; i++) {
          _sealAllowList[addresses[i]] = true;
    }
  } 

  function setPlanktonAllowList(address[] calldata addresses) external onlyOwner {
    for (uint256 i = 0; i < addresses.length; i++) {
          _planktonAllowList[addresses[i]] = true;
    }
  } 

  function whaleMintAllowList() external payable { //see if we can consolidate logic//dry:dont repeat yourself
      require(isWhaleAllowListActive, "Allow list is not active");
      require(PRICE_PER_WHALE_TOKEN * numberOfTokens <= msg.value, "Ether value sent is not correct");
      _whaleAllowList[msg.sender] = false;
      mintRandomWhaleNFT();
    }
  }

  function sealMintAllowList() external payable {
      require(isSealAllowListActive, "Allow list is not active");
      require(PRICE_PER_SEAL_TOKEN * numberOfTokens <= msg.value, "Ether value sent is not correct");
      _whaleAllowList[msg.sender] = false;
          mintRandomSealNFT();
    }
  }

  function planktonMintAllowList(uint8 numberOfTokens) external payable {
      require(isPlanktonAllowListActive, "Allow list is not active");
      require(numberOfTokens <= _planktonAllowList[msg.sender], "Exceeded max available to purchase");
      require(PRICE_PER_PLANKTON_TOKEN * numberOfTokens <= msg.value, "Ether value sent is not correct");

      _planktonAllowList[msg.sender] -= numberOfTokens;
      for (uint256 i = 0; i < numberOfTokens; i++) {
          mintRandomPlanktonNFT();
    }
  }
}