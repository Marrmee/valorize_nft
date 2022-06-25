// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "./ProductNft.sol";

contract ExposedProductNft is ProductNft {
    constructor(
        string memory baseURI_, 
        uint16 _startRarerTokenIdIndex, 
        uint16 _startRareTokenIdIndex) 
        ProductNft(baseURI_, _startRarerTokenIdIndex, _startRareTokenIdIndex) {
        }

    function _rarestTokenIds() external view returns (Counters.Counter memory) {
        return rarestTokenIds;
    }

    function _rarerTokenIds() external view returns (Counters.Counter memory) {
        return rarerTokenIds;
    }

    function _rareTokenIds() external view returns (Counters.Counter memory) {
        return rareTokenIds;
    }

    function _royaltyDistributorAddress() external view returns (address) {
        return royaltyDistributorAddress;
    }

    function _addressProductNFTArtist() external view returns (address) {
        return addressProductNFTArtist;
    }

    function _turnAmountIntoArray(uint256 amount) external pure returns (uint256[] memory) {
        return super.turnAmountIntoArray(amount);
    }

    function _countBasedOnRarity(uint256 rarity) external returns (uint256) {
        return super.countBasedOnRarity(rarity);
    }

    function _initialProductStatusBasedOnRarity(uint256 tokenId,uint256 rarity) external {
        return super.initialProductStatusBasedOnRarity(tokenId,rarity);
    }

    function _turnTokenIdsIntoArray(uint256 rarity,uint256 amount) external returns (uint256[] memory) {
        return super.turnTokenIdsIntoArray(rarity,amount);
    }

    function _emitTokenInfo(uint256 _tokenId) external {
        return super.emitTokenInfo(_tokenId);
    }

}
