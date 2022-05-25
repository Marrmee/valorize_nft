//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

//import "./RoyaltyDistributor.sol";
import "./WhiteListed.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
@title MembershipNft
@author Marco Huberts & Javier Gonzalez
@dev Implementation of a Membership Non Fungible Token using ERC721.
*/

contract ProductNft is ERC721, Ownable {
  string public URI;
  uint256 public constant PRICE_PER_RARE_TOKEN = 1.5 ether;
  uint256 public constant PRICE_PER_RARER_TOKEN = 0.55 ether;
  uint256 public constant PRICE_PER_DISTANT_TOKEN = 0.2 ether;
  uint256 public rarestTokensLeft;
  uint256 public rarerTokensLeft;
  uint256 public rareTokensLeft;
  uint16 startRarer;
  uint16 startRare;
  uint16[] remainingRarerTokenIds;

  mapping(string => RemainingRarerMints) public RarityTraitsByKey;

  struct RemainingRarerMints {
    uint16 Obsidian;
    uint16 Diamond;
    uint16 Gold;
  }


    constructor(    
    string memory _name, 
    string memory _symbol, 
    string memory _URI,
    uint16 _startRarer,
    uint16 _startRare,
    uint16 _rarestTokensLeft,
    uint16 _rarerTokensLeft,
    uint16 _rareTokensLeft,
    uint16[] memory _remainingRarerTokenIds
    ) ERC721(_name, _symbol) {
        URI = _URI;
        startRarer = _startRarer;
        startRare = _startRare;
        rarestTokensLeft = _rarestTokensLeft;
        rarerTokensLeft = _rarerTokensLeft;
        rareTokensLeft = _rareTokensLeft;
        remainingRarerTokenIds = _remainingRarerTokenIds;
        RarityTraitsByKey["Rarer"] = RemainingRarerMints(remainingRarerTokenIds[0], remainingRarerTokenIds[1], remainingRarerTokenIds[2]);
    }

    function _baseURI() internal view override returns (string memory) {
    return URI;
    }

    function _safeMint(address to, uint256 tokenId) override internal virtual {
        _safeMint(to, tokenId, "");
    }
    
    function rarestMint() public payable {
        require(PRICE_PER_RARE_TOKEN <= msg.value, "Ether value sent is not correct");
        _safeMint(msg.sender, rarestTokensLeft, " ");
        rarestTokensLeft--;
    }
//Do we want to mint the Obsidian NFTs first instead of random? 
    function rarerMint() public payable {
        uint256 i = uint256(uint160(address(msg.sender)));
        uint256 rarerTokenId = startRarer + (block.difficulty + i / rarerTokensLeft) % rarerTokensLeft + 1; 
        rarerTokensLeft--;
        require(PRICE_PER_RARER_TOKEN <= msg.value, "Ether value sent is not correct");
        if (rarerTokenId <= remainingRarerTokenIds[0] && RarityTraitsByKey["Rarer"].Obsidian > 0) {
            _safeMint(msg.sender, RarityTraitsByKey["Rarer"].Obsidian, ''); 
            RarityTraitsByKey["Rarer"].Obsidian--;
        } else if (rarerTokenId <= remainingRarerTokenIds[1] && RarityTraitsByKey["Rarer"].Diamond >= (remainingRarerTokenIds[0]+1)) {
            _safeMint(msg.sender, RarityTraitsByKey["Rarer"].Diamond, ''); 
            RarityTraitsByKey["Rarer"].Diamond--;
        } else if (rarerTokenId <= remainingRarerTokenIds[2] && RarityTraitsByKey["Rarer"].Gold >= (remainingRarerTokenIds[1]+1)) {
            _safeMint(msg.sender, RarityTraitsByKey["Rarer"].Gold, ''); 
            RarityTraitsByKey["Rarer"].Gold--;
        }
    }

    function rareMint() public payable {
        require(PRICE_PER_RARE_TOKEN <= msg.value, "Ether value sent is not correct");
        _safeMint(msg.sender, rareTokensLeft, " ");
        rareTokensLeft--;
    }

}
