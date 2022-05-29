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
        uint16 _startSeal_,
        uint16 _startPlankton_,
        uint16 _whaleTokensLeft_,
        uint16 _sealTokensLeft_,
        uint16 _planktonTokensLeft_,
        uint16[] memory _remainingWhaleTokenIds,
        uint16[] memory _remainingSealTokenIds,
        uint16[] memory _remainingPlanktonTokenIds
    ) MembershipNft(_name_, _symbol_, _URI_, _startSeal_, _startPlankton_, _whaleTokensLeft_, _sealTokensLeft_, _planktonTokensLeft_, _remainingWhaleTokenIds, _remainingSealTokenIds, _remainingPlanktonTokenIds) {
        URI = _URI_;
    }

    function whaleMint(address recipient, uint256 whaleTokenId, bytes memory data) public {
        return _whaleMint(recipient, whaleTokenId, data);
    }

    function sealMint(address recipient, uint256 sealTokenId, bytes memory data) public {
        return _sealMint(recipient, sealTokenId, data);
    }

    function planktonMint(address recipient, uint256 planktonTokenId, bytes memory data) public {
        return _planktonMint(recipient, planktonTokenId, data);
    }
}
