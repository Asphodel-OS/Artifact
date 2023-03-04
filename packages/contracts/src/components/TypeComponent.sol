// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "std-contracts/components/StringComponent.sol";

uint256 constant ID = uint256(keccak256("component.type"));

// The type of an entity. Used between different contexts.
// On Registries this is the lowest tier of taxonomy.
// On Commitments this is the type of action being committed.
contract TypeComponent is StringComponent {
  constructor(address world) StringComponent(world, ID) {}
}
