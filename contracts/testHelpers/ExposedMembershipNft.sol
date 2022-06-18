//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

import "../MembershipNft.sol";

/**
@title MembershipNft
@author Marco Huberts & Javier Gonzalez
@dev Implementation of a Membership Non Fungible Token using ERC721B.
*/

contract ExposedMembershipNft is MembershipNft {

    constructor (
        string memory _name_, 
        string memory _symbol_, 
        string memory _URI_,
        uint16 _whaleTokensLeft_,
        uint16 _sealTokensLeft_,
        uint16 _planktonTokensLeft_,
        uint16[] memory _remainingWhaleTokenIds,
        uint16[] memory _remainingSealTokenIds,
        uint16[] memory _remainingPlanktonTokenIds
    ) MembershipNft(_name_, _symbol_, _URI_, _whaleTokensLeft_, _sealTokensLeft_, _planktonTokensLeft_, _remainingWhaleTokenIds, _remainingSealTokenIds, _remainingPlanktonTokenIds) {
        URI = _URI_;
    }

    function mint(address recipient, uint256 tokenId) public {
        return _selectiveMint(recipient, tokenId);
    }
}
