//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
@title MembershipNft
@author Marco Huberts & Javier Gonzalez
@dev Implementation of a Membership Non Fungible Token using ERC721.
*/

contract MembershipNft is ERC721, Ownable {

  bool public isAllowListActive = false;
  string public URI;
  uint256 public whaleTokensLeft = 50;
  uint256 public sealTokensLeft = 150;
  uint256 public planktonTokensLeft = 2800;
  mapping(address => bool) public AllowList;
  mapping(address => uint256) public ChoiceList;
  mapping(string => RemainingMints) public RarityTraitsByKey;
  RemainingMints remainingMints;
  
  struct RemainingMints {
    uint16 Mycelia;
    uint16 Obsidian;
    uint16 Diamond;
    uint16 Gold;
    uint16 Silver;
  }

  constructor(
    string memory name, 
    string memory symbol, 
    string memory _URI
  ) ERC721(name, symbol) {
    URI = _URI;
    RarityTraitsByKey["Whale"] = RemainingMints(3, 18, 50, 0, 0);
    RarityTraitsByKey["Seal"] = RemainingMints(53, 68, 125, 200, 0);
    RarityTraitsByKey["Plankton"] = RemainingMints(203, 223, 375, 1300, 3000);
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
    require(1.0 ether <= msg.value, "Ether value sent is not correct");

    if (whaleTokenId <= 3 && RarityTraitsByKey["Whale"].Mycelia > 0) {
      _whaleMint(msg.sender, RarityTraitsByKey["Whale"].Mycelia, ''); 
      RarityTraitsByKey["Whale"].Mycelia--;
    } else if (whaleTokenId <= 18 && RarityTraitsByKey["Whale"].Obsidian >= 4) {
      _whaleMint(msg.sender, RarityTraitsByKey["Whale"].Obsidian, ''); 
      RarityTraitsByKey["Whale"].Obsidian--;
    } else if (whaleTokenId <= 50 && RarityTraitsByKey["Whale"].Diamond >= 19) {
      _whaleMint(msg.sender, RarityTraitsByKey["Whale"].Diamond, ''); 

      RarityTraitsByKey["Whale"].Diamond--;
    }
  }

  function mintRandomSealNFT() public payable {
    uint256 i = uint256(uint160(address(msg.sender)));
    uint256 sealTokenId = 50 + ((block.difficulty + i / sealTokensLeft) % sealTokensLeft + 1);
    sealTokensLeft--;
    require(0.2 ether <= msg.value, "Ether value sent is not correct");

    if (sealTokenId <= 53 && RarityTraitsByKey["Seal"].Mycelia >= 51) {
      _sealMint(msg.sender, RarityTraitsByKey["Seal"].Mycelia, ''); 
      RarityTraitsByKey["Seal"].Mycelia--;
    } else if (sealTokenId <= 68 && RarityTraitsByKey["Seal"].Obsidian >= 54) {
      _sealMint(msg.sender, RarityTraitsByKey["Seal"].Obsidian, '');
      RarityTraitsByKey["Seal"].Obsidian--;
    } else if (sealTokenId <= 125 && RarityTraitsByKey["Seal"].Diamond >= 69) {
      _sealMint(msg.sender, RarityTraitsByKey["Seal"].Diamond, ''); 
      RarityTraitsByKey["Seal"].Diamond--;
    } else if (sealTokenId <= 200 && RarityTraitsByKey["Seal"].Gold >= 126) {
      _sealMint(msg.sender, RarityTraitsByKey["Seal"].Gold, ''); 
      RarityTraitsByKey["Seal"].Gold--;
    }
  }

  function mintRandomPlanktonNFT() public payable {
    uint256 i = uint256(uint160(address(msg.sender)));
    uint256 planktonTokenId = 200 + ((block.difficulty + i / planktonTokensLeft) % planktonTokensLeft + 1);
    planktonTokensLeft--; 
    require(0.1 ether <= msg.value, "Ether value sent is not correct");

    if (planktonTokenId <= 203 && RarityTraitsByKey["Plankton"].Mycelia >= 201) {
      _planktonMint(msg.sender, RarityTraitsByKey["Plankton"].Mycelia, '');
      RarityTraitsByKey["Plankton"].Mycelia--;
    } else if (planktonTokenId <= 223 && RarityTraitsByKey["Plankton"].Obsidian >= 204) {
      _planktonMint(msg.sender, RarityTraitsByKey["Plankton"].Obsidian, ''); 
      RarityTraitsByKey["Plankton"].Obsidian--;
    } else if (planktonTokenId <= 375  && RarityTraitsByKey["Plankton"].Diamond >= 224) {
      _planktonMint(msg.sender, RarityTraitsByKey["Plankton"].Diamond, '');
      RarityTraitsByKey["Plankton"].Diamond--;
    } else if (planktonTokenId <= 1300 && RarityTraitsByKey["Plankton"].Gold >= 376) {
      _planktonMint(msg.sender, RarityTraitsByKey["Plankton"].Gold, ''); 
      RarityTraitsByKey["Plankton"].Gold--;
    } else if (planktonTokenId <= 3000 && RarityTraitsByKey["Plankton"].Silver >= 1301) {
      _planktonMint(msg.sender, RarityTraitsByKey["Plankton"].Silver, ''); 
      RarityTraitsByKey["Plankton"].Silver--;
    }
  }

  function _whaleMint(address recipient, uint256 whaleTokenId, bytes memory data) internal {
    require(whaleTokenId >= 1 && whaleTokenId <= 50, "the whale NFTs are sold out");
    _safeMint(recipient, whaleTokenId, data);
  }

  function _sealMint(address recipient, uint256 sealTokenId, bytes memory data) internal {
    require(sealTokenId >= 51 && sealTokenId <= 200, "the seal NFTs are sold out");
    _safeMint(recipient, sealTokenId, data);
  }

  function _planktonMint(address recipient, uint256 planktonTokenId, bytes memory data) internal {
    require(planktonTokenId >= 201 && planktonTokenId <= 3000, "the plankton NFTs are sold out");
    _safeMint(recipient, planktonTokenId, data);
  }

  function setIsAllowListActive(bool _isAllowListActive) external onlyOwner {
      isAllowListActive = _isAllowListActive;
  }

  function numAvailableToMint(address addr) external view returns (bool) {
        return AllowList[addr];
  }

  //this function forces us to set the allow list (at least) three times
  //sort the list of addresses based on choice and then set the list three times

  // function setAllowList(address[] calldata addresses, uint256 choice) external onlyOwner {
  //   for (uint256 i = 0; i < addresses.length; i++) {
  //         _allowList[addresses[i]] = true;
  //         _choiceList[addresses[i]] = choice;
  // }
//this function should now get one mapping _allowList that contains addresses with choice 1, 2 or 3
  function setAllowLists(
    address[] calldata whaleAddresses, 
    address[] calldata sealAddresses,
    address[] calldata planktonAddresses) external onlyOwner {
    for (uint256 i = 0; i < whaleAddresses.length; i++) {
          AllowList[whaleAddresses[i]] = true;
          ChoiceList[whaleAddresses[i]] = 1; 
    }
    for (uint256 i = 0; i < sealAddresses.length; i++) {
          AllowList[sealAddresses[i]] = true;
          ChoiceList[sealAddresses[i]] = 2;
    }
    for (uint256 i = 0; i < planktonAddresses.length; i++) {
          AllowList[planktonAddresses[i]] = true;
          ChoiceList[planktonAddresses[i]] = 3; 
    }
  }


  function allowListMint() external payable {
    require(isAllowListActive == true, "Allow list is not active");
    require(AllowList[msg.sender] == true, "you already minted an NFT");
    if (ChoiceList[msg.sender] == 1) {
      require(1.0 ether <= msg.value, "Ether value sent is not correct");
      mintRandomWhaleNFT();
      AllowList[msg.sender] = false;
    } else if (ChoiceList[msg.sender] == 2) {
      require(0.2 ether <= msg.value, "Ether value sent is not correct");
      mintRandomSealNFT();
      AllowList[msg.sender] = false;
    } else if (ChoiceList[msg.sender] == 3) {
      require(0.1 ether <= msg.value, "Ether value sent is not correct");
      mintRandomPlanktonNFT();
      AllowList[msg.sender] = false;
    }
  }
}