// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "std-contracts/components/Uint256Component.sol";

uint256 constant ID = uint256(keccak256("component.probability.fail"));

// probability of failure. represents the odds of a possibile negative result
// rather than a non-action. common use case is with scrolls where there can
// be both a probability of non-success (no successful upgrade) and a probability
// of failure beyond non-success (equipment is destroyed)
contract ProbabilityFailComponent is Uint256Component {
  constructor(address world) Uint256Component(world, ID) {}
}
