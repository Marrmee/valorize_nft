//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract WhiteListed is Ownable {

bool public isAllowListActive = false;
mapping(address => bool) public AllowList;
mapping(address => uint256) public ChoiceList;

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
}