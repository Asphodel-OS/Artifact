// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "std-contracts/components/Uint256BareComponent.sol";

uint256 constant ID = uint256(keccak256("component.range"));

// range value of an entity
contract RangeComponent is Uint256BareComponent {
  constructor(address world) Uint256BareComponent(world, ID) {}
}
