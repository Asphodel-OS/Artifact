// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "std-contracts/components/Uint256BareComponent.sol";

uint256 constant ID = uint256(keccak256("component.level"));

// level value of an entity. on items this is interpreted as a level limit.
// on characters, this is interpreted as an actual level.
contract LevelComponent is Uint256BareComponent {
  constructor(address world) Uint256BareComponent(world, ID) {}
}
