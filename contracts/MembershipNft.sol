//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
@title MembershipNft
@author Marco Huberts & Javier Gonzalez
@dev Implementation of a Community Non Fungible Token using ERC721B.
*/

contract MembershipNft is ERC721, Ownable {

  bool public isAllowListActive = false;
  uint256 public constant PRICE_PER_WHALE_TOKEN = 1.0 ether;
  uint256 public constant PRICE_PER_SEAL_TOKEN = 0.2 ether;
  uint256 public constant PRICE_PER_PLANKTON_TOKEN = 0.1 ether;
  string public URI;

  mapping(address => bool) private _allowList;
  mapping(address => uint256) _choiceList;

  uint256 public whaleTokensLeft = 50;
  uint256 public sealTokensLeft = 150;
  uint256 public planktonTokensLeft = 2800;

  uint256 public remainingWhaleMyceliaId = 3; 
  uint256 public remainingWhaleObsidianId = 18;
  uint256 public remainingWhaleDiamondId = 50;

  uint256 public remaningSealMyceliaId = 53;
  uint256 public remaningSealObsidianId = 68;
  uint256 public remaningSealDiamondId = 125;
  uint256 public remaningSealGoldId = 200;
  
  uint256 public remaningPlanktonMyceliaId = 203;
  uint256 public remaningPlanktonObsidianId = 223;
  uint256 public remaningPlanktonDiamondId = 375;
  uint256 public remaningPlanktonGoldId = 1300;
  uint256 public remaningPlanktonSilverId = 3000;

  constructor(
    string memory name, 
    string memory symbol, 
    string memory _URI
  ) ERC721(name, symbol) {
    URI = _URI;
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
    whaleTokensLeft--;
    require(PRICE_PER_WHALE_TOKEN == msg.value, "Ether value sent is not correct");

    if (whaleTokenId <= 3 && remainingWhaleMyceliaId > 0) {
      whaleMint(msg.sender, remainingWhaleMyceliaId, ''); 
      remainingWhaleMyceliaId--;
    } else if (whaleTokenId <= 18 && remainingWhaleObsidianId >= 4) {
      whaleMint(msg.sender, remainingWhaleMyceliaId, ''); 
      remainingWhaleObsidianId--;
    } else if (whaleTokenId <= 50 && remainingWhaleDiamondId >= 19) {
      whaleMint(msg.sender, remainingWhaleDiamondId, ''); 
      remainingWhaleDiamondId--;
    }
  }

  function mintRandomSealNFT() public payable {
    uint256 i = uint256(uint160(address(msg.sender)));
    uint256 sealTokenId = 50 + ((block.difficulty + i / sealTokensLeft) % sealTokensLeft + 1);
    sealTokensLeft--;
    require(PRICE_PER_SEAL_TOKEN == msg.value, "Ether value sent is not correct");

    if (sealTokenId <= 53 && remaningSealMyceliaId >= 51) {
      sealMint(msg.sender, remaningSealMyceliaId, ''); 
      remaningSealMyceliaId--;
    } else if (sealTokenId <= 68 && remaningSealObsidianId >= 54) {
      sealMint(msg.sender, remaningSealObsidianId, '');
      remaningSealObsidianId--;
    } else if (sealTokenId <= 125 && remaningSealDiamondId >= 69) {
      sealMint(msg.sender, remaningSealDiamondId, ''); 
      remaningSealDiamondId--;
    } else if (sealTokenId <= 200 && remaningSealGoldId >= 126) {
      sealMint(msg.sender, remaningSealGoldId, ''); 
      remaningSealGoldId--;
    }
  }

  function mintRandomPlanktonNFT() public payable {
    uint256 i = uint256(uint160(address(msg.sender)));
    uint256 planktonTokenId = 200 + ((block.difficulty + i / planktonTokensLeft) % planktonTokensLeft + 1);
    planktonTokensLeft--; 
    require(PRICE_PER_PLANKTON_TOKEN == msg.value, "Ether value sent is not correct");

    if (planktonTokenId <= 203 && remaningPlanktonMyceliaId >= 201) {
      planktonMint(msg.sender, remaningPlanktonMyceliaId, '');
      remaningPlanktonMyceliaId--;
    } else if (planktonTokenId <= 223 && remaningPlanktonObsidianId >= 204) {
      planktonMint(msg.sender, remaningPlanktonObsidianId, ''); 
      remaningPlanktonObsidianId--;
    } else if (planktonTokenId <= 375  && remaningPlanktonDiamondId >= 224) {
      planktonMint(msg.sender, remaningPlanktonDiamondId, '');
      remaningPlanktonDiamondId--;
    } else if (planktonTokenId <= 1300 && remaningPlanktonGoldId >= 376) {
      planktonMint(msg.sender, remaningPlanktonGoldId, ''); 
      remaningPlanktonGoldId--;
    } else if (planktonTokenId <= 3000 && remaningPlanktonSilverId >= 1301) {
      planktonMint(msg.sender, remaningPlanktonSilverId, ''); 
      remaningPlanktonSilverId--;
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

  function setIsAllowListActive(bool _isAllowListActive) external onlyOwner {
      isAllowListActive = _isAllowListActive;
  }

  function numAvailableToMint(address addr) external view returns (bool) {
        return _allowList[addr];
  }

  function setAllowList(address[] calldata addresses, uint256 choice) external onlyOwner {
    require(choice > 0 && choice <= 3, "choice can only be 1 (whale), 2 (seal) or 3 (plankton)");
    for (uint256 i = 0; i < addresses.length; i++) {
          _allowList[addresses[i]] = true;
          _choiceList[addresses[i]] = choice; 
    }
  }

  function allowListMint() external payable {
    require(isAllowListActive, "Allow list is not active");
    require(_allowList[msg.sender] == true, "you already minted an NFT");
    if (_choiceList[msg.sender] == 1) {
      require(PRICE_PER_WHALE_TOKEN <= msg.value, "Ether value sent is not correct");
      mintRandomWhaleNFT();
      _allowList[msg.sender] = false;
    } else if (_choiceList[msg.sender] == 2) {
      require(PRICE_PER_SEAL_TOKEN <= msg.value, "Ether value sent is not correct");
      mintRandomSealNFT();
      _allowList[msg.sender] = false;
    } else if (_choiceList[msg.sender] == 3) {
      require(PRICE_PER_PLANKTON_TOKEN <= msg.value, "Ether value sent is not correct");
      mintRandomPlanktonNFT();
      _allowList[msg.sender] = false;
    }
  }
}