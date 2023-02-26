// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "std-contracts/components/Uint256Component.sol";

uint256 constant ID = uint256(keccak256("component.index.consumable"));

// represents the registry index of Consumables, this is always used alongside the
// Item Index and used primarily for ease of human readability
contract IndexConsumableComponent is Uint256Component {
  constructor(address world) Uint256Component(world, ID) {}
}
