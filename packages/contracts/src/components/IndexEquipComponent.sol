// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "std-contracts/components/Uint256Component.sol";

uint256 constant ID = uint256(keccak256("component.index.equip"));

// represents the registry index of Equipment, this is always used alongside the
// Item Index and used primarily for ease of human readability
contract IndexEquipComponent is Uint256Component {
  constructor(address world) Uint256Component(world, ID) {}
}
