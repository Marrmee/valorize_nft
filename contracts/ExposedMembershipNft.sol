//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

import "./MembershipNft_V2.sol";

/**
@title MembershipNft
@author Marco Huberts & Javier Gonzalez
@dev Implementation of a Membership Non Fungible Token using ERC721B.
*/

contract ExposedMembershipNft is MembershipNft_V2 {

    constructor (
        string memory _name, 
        string memory _symbol, 
        string memory _URI_
    ) MembershipNft_V2(_name, _symbol, _URI_) {
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
