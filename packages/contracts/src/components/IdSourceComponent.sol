// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "std-contracts/components/Uint256Component.sol";

uint256 constant ID = uint256(keccak256("component.id.source"));

// A reference to a source of effects for an interaction. Represented as that entity's ID.
// As an example, a item enhancement's source would be the scroll used to enhance the item
contract IdSourceComponent is Uint256Component {
  constructor(address world) Uint256Component(world, ID) {}
}
