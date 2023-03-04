// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "std-contracts/components/BoolComponent.sol";

uint256 constant ID = uint256(keccak256("component.is.commit"));

// identifies an entity as a committed random roll. this entity can then be accessed
// and triggered by the owner of the roll
contract IsCommitComponent is BoolComponent {
  constructor(address world) BoolComponent(world, ID) {}
}
