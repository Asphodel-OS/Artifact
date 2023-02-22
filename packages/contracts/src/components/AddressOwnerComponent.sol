// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import { AddressComponent } from "std-contracts/components/AddressComponent.sol";

uint256 constant ID = uint256(keccak256("component.address.owner"));

// The address of the ethereum account that owns game assets and controls the player account
contract AddressOwnerComponent is AddressComponent {
  constructor(address world) AddressComponent(world, ID) {}
}
