
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract RoyaltyDistributorProductNft {

  string URI;

  constructor(  
    string memory _URI
  ) {
    URI = _URI;
  }

  address payable artist;
  address payable valorize = payable(0x43402200629A8Ea23F0A8B7eC9E0587fAdc9616b);

  struct GenerativeRoyaltyInfo {
    address payable artistAddress;
    address payable valorizeAddress;
    uint96 royaltyAmount;
  }

  mapping(uint256 => GenerativeRoyaltyInfo) public generativeTokenRoyalty;

  function calculateGenerativeRoyalty(uint256 _salePrice) pure public returns(uint256) {
    return (_salePrice / 100) * 5;
  }

  function _setGenerativeTokenRoyalty(
    uint256[] memory tokenIds
  ) internal virtual {
      for(uint256 i=0; i <= tokenIds.length; i++) {
        require(artist != address(0), "ERC2981: Invalid parameters");
        generativeTokenRoyalty[tokenIds[i]] = GenerativeRoyaltyInfo(artist, valorize, 5);
      }
  }

  function generativeTokenRoyaltyInfo(uint256 _tokenId, uint256 _salePrice) public virtual returns (address, address, uint256) {
    GenerativeRoyaltyInfo memory generativeRoyalty = generativeTokenRoyalty[_tokenId];
    uint256 royaltyAmount = calculateGenerativeRoyalty(_salePrice);
    (generativeRoyalty.artistAddress).transfer(royaltyAmount);
    (generativeRoyalty.valorizeAddress).transfer(royaltyAmount);
    return (generativeRoyalty.artistAddress, generativeRoyalty.valorizeAddress, royaltyAmount);
  }
}
//An ethereum address belonging to the contractor will be put in the contract’s 
//royalty calculator as per the EIP-2981 royalty standard for the sales of 
//their 1 of 1 nft with a 10% royalty fee. 

//For the artworks generated by the 
//contractor that will not be 1 of 1, payment royalties will be directed 
//to a smart contract that will split those royalties 5% for the 
//contractor’s address and 5% for an address belonging to Valorize.