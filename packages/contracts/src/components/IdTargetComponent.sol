// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "std-contracts/components/Uint256Component.sol";

uint256 constant ID = uint256(keccak256("component.id.target"));

// A reference to a target of an interaction. Represented as that entity's ID
contract IdTargetComponent is Uint256Component {
  constructor(address world) Uint256Component(world, ID) {}
}
