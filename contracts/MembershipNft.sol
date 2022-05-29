//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./RoyaltyDistributor.sol";
import "./WhiteListed.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
@title MembershipNft
@author Marco Huberts & Javier Gonzalez
@dev Implementation of a Membership Non Fungible Token using ERC721.
*/

contract MembershipNft is ERC721, WhiteListed {

  string public URI;
  uint256 public constant PRICE_PER_WHALE_TOKEN = 1.0 ether;
  uint256 public constant PRICE_PER_SEAL_TOKEN = 0.2 ether;
  uint256 public constant PRICE_PER_PLANKTON_TOKEN = 0.1 ether;
  uint256 public whaleTokensLeft;
  uint256 public sealTokensLeft;
  uint256 public planktonTokensLeft;
  uint16 startSeal;
  uint16 startPlankton;
  uint16[] remainingWhaleTokenIds;
  uint16[] remainingSealTokenIds;
  uint16[] remainingPlanktonTokenIds;

  mapping(string => RemainingMints) public RarityTraitsByKey;

  struct RemainingMints {
    uint16 Mycelia;
    uint16 Obsidian;
    uint16 Diamond;
    uint16 Gold;
    uint16 Silver;
  }

  constructor(
    string memory _name, 
    string memory _symbol, 
    string memory _URI,
    uint16 _startSeal,
    uint16 _startPlankton,
    uint16 _whaleTokensLeft,
    uint16 _sealTokensLeft,
    uint16 _planktonTokensLeft,
    uint16[] memory _remainingWhaleTokenIds,
    uint16[] memory _remainingSealTokenIds,
    uint16[] memory _remainingPlanktonTokenIds
  ) ERC721(_name, _symbol) {
    URI = _URI;
    startSeal = _startSeal;
    startPlankton = _startPlankton;
    whaleTokensLeft = _whaleTokensLeft;
    sealTokensLeft = _sealTokensLeft;
    planktonTokensLeft = _planktonTokensLeft;
    remainingWhaleTokenIds = _remainingWhaleTokenIds;
    remainingSealTokenIds = _remainingSealTokenIds;
    remainingPlanktonTokenIds = _remainingPlanktonTokenIds;
    RarityTraitsByKey["Whale"] = RemainingMints(remainingWhaleTokenIds[0], remainingWhaleTokenIds[1], remainingWhaleTokenIds[2], 0, 0);
    RarityTraitsByKey["Seal"] = RemainingMints(remainingSealTokenIds[0], remainingSealTokenIds[1], remainingSealTokenIds[2], remainingSealTokenIds[3], 0);
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
    whaleTokensLeft--;
    require(PRICE_PER_WHALE_TOKEN <= msg.value, "Ether value sent is not correct");
//test to see if changing the tokenId gives a different rarity call 
    if (whaleTokenId <= remainingWhaleTokenIds[0] && RarityTraitsByKey["Whale"].Mycelia > 0) {
      _whaleMint(msg.sender, RarityTraitsByKey["Whale"].Mycelia, ''); 
      RarityTraitsByKey["Whale"].Mycelia--;
    } else if (whaleTokenId <= remainingWhaleTokenIds[1] && RarityTraitsByKey["Whale"].Obsidian >= (remainingWhaleTokenIds[0]+1)) {
      _whaleMint(msg.sender, RarityTraitsByKey["Whale"].Obsidian, ''); 
      RarityTraitsByKey["Whale"].Obsidian--;
    } else if (whaleTokenId <= remainingWhaleTokenIds[2] && RarityTraitsByKey["Whale"].Diamond >= (remainingWhaleTokenIds[1]+1)) {
      _whaleMint(msg.sender, RarityTraitsByKey["Whale"].Diamond, ''); 
      RarityTraitsByKey["Whale"].Diamond--;
    }
  }

  function mintRandomSealNFT() public payable {
    uint256 i = uint256(uint160(address(msg.sender)));
    uint256 sealTokenId = startSeal + ((block.difficulty + i / sealTokensLeft) % sealTokensLeft + 1);
    sealTokensLeft--;
    require(PRICE_PER_SEAL_TOKEN <= msg.value, "Ether value sent is not correct");

    if (sealTokenId <= remainingSealTokenIds[0] && RarityTraitsByKey["Seal"].Mycelia >= (startSeal + 1)) {
      _sealMint(msg.sender, RarityTraitsByKey["Seal"].Mycelia, ''); 
      RarityTraitsByKey["Seal"].Mycelia--;
    } else if (sealTokenId <= remainingSealTokenIds[1] && RarityTraitsByKey["Seal"].Obsidian >= (remainingSealTokenIds[0] + 1)) {
      _sealMint(msg.sender, RarityTraitsByKey["Seal"].Obsidian, '');
      RarityTraitsByKey["Seal"].Obsidian--;
    } else if (sealTokenId <= remainingSealTokenIds[2] && RarityTraitsByKey["Seal"].Diamond >= (remainingSealTokenIds[1] + 1)) {
      _sealMint(msg.sender, RarityTraitsByKey["Seal"].Diamond, ''); 
      RarityTraitsByKey["Seal"].Diamond--;
    } else if (sealTokenId <= remainingSealTokenIds[3] && RarityTraitsByKey["Seal"].Gold >= (remainingSealTokenIds[2] + 1)) {
      _sealMint(msg.sender, RarityTraitsByKey["Seal"].Gold, ''); 
      RarityTraitsByKey["Seal"].Gold--;
    }
  }

  function mintRandomPlanktonNFT() public payable {
    uint256 i = uint256(uint160(address(msg.sender)));
    uint256 planktonTokenId = startPlankton + ((block.difficulty + i / planktonTokensLeft) % planktonTokensLeft + 1);
    planktonTokensLeft--; 
    require(PRICE_PER_PLANKTON_TOKEN <= msg.value, "Ether value sent is not correct");

    if (planktonTokenId <= remainingPlanktonTokenIds[0] && RarityTraitsByKey["Plankton"].Mycelia >= (startPlankton + 1)) {
      _planktonMint(msg.sender, RarityTraitsByKey["Plankton"].Mycelia, '');
      RarityTraitsByKey["Plankton"].Mycelia--;
    } else if (planktonTokenId <= remainingPlanktonTokenIds[1] && RarityTraitsByKey["Plankton"].Obsidian >= (remainingPlanktonTokenIds[0] + 1)) {
      _planktonMint(msg.sender, RarityTraitsByKey["Plankton"].Obsidian, ''); 
      RarityTraitsByKey["Plankton"].Obsidian--;
    } else if (planktonTokenId <= remainingPlanktonTokenIds[2]  && RarityTraitsByKey["Plankton"].Diamond >= (remainingPlanktonTokenIds[1] + 1)) {
      _planktonMint(msg.sender, RarityTraitsByKey["Plankton"].Diamond, '');
      RarityTraitsByKey["Plankton"].Diamond--;
    } else if (planktonTokenId <= remainingPlanktonTokenIds[3] && RarityTraitsByKey["Plankton"].Gold >= (remainingPlanktonTokenIds[2] + 1)) {
      _planktonMint(msg.sender, RarityTraitsByKey["Plankton"].Gold, ''); 
      RarityTraitsByKey["Plankton"].Gold--;
    } else if (planktonTokenId <= remainingPlanktonTokenIds[4] && RarityTraitsByKey["Plankton"].Silver >= (remainingPlanktonTokenIds[3] + 1)) {
      _planktonMint(msg.sender, RarityTraitsByKey["Plankton"].Silver, ''); 
      RarityTraitsByKey["Plankton"].Silver--;
    }
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

  // function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns (bool) {
  //   return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
  // }
  
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
}