// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "std-contracts/components/StringComponent.sol";

uint256 constant ID = uint256(keccak256("component.type"));

// the type (taxonomy tier) of an entity
contract TypeComponent is StringComponent {
  constructor(address world) StringComponent(world, ID) {}
}
