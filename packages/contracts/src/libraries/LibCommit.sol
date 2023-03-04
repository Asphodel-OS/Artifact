// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibString } from "solady/utils/LibString.sol";
import { IUint256Component as IComponents } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById } from "solecs/utils.sol";

import { IdHolderComponent, ID as IdHolderCompID } from "components/IdHolderComponent.sol";
import { IdSourceComponent, ID as IdSourceCompID } from "components/IdSourceComponent.sol";
import { IdTargetComponent, ID as IdTargetCompID } from "components/IdTargetComponent.sol";
import { IsCommitComponent, ID as IsCommitCompID } from "components/IsCommitComponent.sol";
import { IsInventoryComponent, ID as IsInventoryCompID } from "components/IsInventoryComponent.sol";
import { IsFungibleComponent, ID as IsFungCompID } from "components/IsFungibleComponent.sol";
import { IsNonFungibleComponent, ID as IsNonFungCompID } from "components/IsNonFungibleComponent.sol";
import { ProbabilitySuccessComponent, ID as ProbSuccCompID } from "components/ProbabilitySuccessComponent.sol";
import { TypeComponent, ID as TypeCompID } from "components/TypeComponent.sol";
import { BlockStartComponent, ID as BlockStartCompID } from "components/BlockStartComponent.sol";
import { LibAccount } from "libraries/LibAccount.sol";
import { LibInventory } from "libraries/LibInventory.sol";
import { LibInventoryNF } from "libraries/LibInventoryNF.sol";

// Q: what to use as the seed?
library LibCommit {
  error InvalidType(string type_);
  error InvalidSource(uint256 sourceID);
  error InvalidTarget(uint256 targetID);
  error TooEarly(uint256 blockStart, uint256 blockNumber);

  /////////////////
  // INTERACTIONS

  // @dev Commit a random action to be executed at a later time. Creates a Commitment entity
  // representing the resulting interaction.
  // @param world The world to create the Commit entity in
  // @param components The components to use for the Commit entity
  // @param probability The probability of the action being executed
  // @param targetID The entityID of the target of the action
  // @param sourceID The entityID of the source of the action. Optional.
  // @param type_ The type of action to be executed [ DESTROY | UPGRADE | CREATE ]
  // NOTE: Commitments don't always need a sourceID, but create it anyways for logical consistency.
  function create(
    IWorld world,
    IComponents components,
    uint256 probability,
    uint256 targetID,
    uint256 sourceID,
    string memory type_
  ) internal returns (uint256) {
    uint256 id = world.getUniqueEntityId();
    uint256 accountID = LibAccount.getByOperator(components, msg.sender);
    IsCommitComponent(getAddressById(components, IsCommitCompID)).set(id);
    IdHolderComponent(getAddressById(components, IdHolderCompID)).set(id, accountID);
    ProbabilitySuccessComponent(getAddressById(components, ProbSuccCompID)).set(id, probability);
    TypeComponent(getAddressById(components, TypeCompID)).set(id, type_);
    IdTargetComponent(getAddressById(components, IdTargetCompID)).set(id, targetID);
    IdSourceComponent(getAddressById(components, IdSourceCompID)).set(id, sourceID);
    BlockStartComponent(getAddressById(components, BlockStartCompID)).set(id, block.number);
    return id;
  }

  // @dev Destroy the specified Commitment entity
  function del(IComponents components, uint256 id) internal {
    getComponentById(components, IsCommitCompID).remove(id);
    getComponentById(components, IdHolderCompID).remove(id);
    getComponentById(components, ProbSuccCompID).remove(id);
    getComponentById(components, TypeCompID).remove(id);
    getComponentById(components, IdTargetCompID).remove(id);
    getComponentById(components, IdSourceCompID).remove(id);
    getComponentById(components, BlockStartCompID).remove(id);
  }

  // @dev Reveal a Commit entity, executing the action if the roll < probability. Delete
  // the commitment if probability was checked.
  // @param world The world
  function reveal(
    IWorld world,
    IComponents components,
    uint256 id
  ) internal returns (bool success) {
    // get a block number offset for hash used in seed (∆max = 256 or 255?)
    uint256 blockDiff = ((block.number - getStartBlock(components, id)) % 255) + 1;
    uint256 blockHash = uint256(blockhash(block.number - blockDiff));
    uint256 roll = random(id ^ blockHash);

    if (roll < getProbability(components, id)) {
      // execute the reveal action depending on the step the type of commitment
      string memory type_ = getType(components, id);
      if (LibString.eq(type_, "CREATE")) {
        revealCreate(world, components, id);
      } else if (LibString.eq(type_, "DESTROY")) {
        revealDestroy(components, id);
      } else if (LibString.eq(type_, "ENHANCE")) {
        revealEnhance();
      } else {
        revert InvalidType(type_);
      }
    }

    // clean up the the commitment
    del(components, id);
    return true;
  }

  // @dev Execute a CREATE Commitment.
  // TODO: atm only handles creation of inventory. implement other use cases (e.g. pet creation)
  function revealCreate(
    IWorld world,
    IComponents components,
    uint256 id
  ) internal returns (uint256) {
    // assume this is an inventory creation. get the source and target
    uint256 accountID = getTarget(components, id);
    uint256 itemRegistryID = getSource(components, id);

    uint256 inventoryID;
    if (LibInventory.isInstance(components, itemRegistryID)) {
      inventoryID = LibInventory.create(world, components, accountID, itemRegistryID);
    } else if (LibInventoryNF.isInstance(components, itemRegistryID)) {
      inventoryID = LibInventoryNF.create(world, components, accountID, itemRegistryID);
    } else {
      revert InvalidSource(itemRegistryID);
    }
    return inventoryID;
  }

  // @dev Execute a DESTROY Commitment.
  // TODO: atm only handles creation inventory. implement other use cases (are there any?)
  function revealDestroy(IComponents components, uint256 id) internal {
    // atm we can just assume this is an inventory destruction
    uint256 entityID = getTarget(components, id);

    if (LibInventory.isInstance(components, entityID)) {
      LibInventory.del(components, entityID);
    } else if (LibInventoryNF.isInstance(components, entityID)) {
      LibInventoryNF.del(components, entityID);
    } else {
      revert InvalidTarget(entityID);
    }
  }

  function revealEnhance() internal returns (uint256) {}

  /////////////////
  // CHECKS

  // @dev Check if a Commit entity can be revealed. At the moment this checks whether the is the owner
  // of the commitment and whether the current block number is greater than the start block.
  function canReveal(IComponents components, uint256 id) internal view returns (bool) {
    return
      IdHolderComponent(getAddressById(components, IdHolderCompID)).getValue(id) ==
      LibAccount.getByOperator(components, msg.sender) &&
      block.number > BlockStartComponent(getAddressById(components, BlockStartCompID)).getValue(id);
  }

  /////////////////
  // COMPONENT RETRIEVAL

  function getProbability(IComponents components, uint256 id) internal view returns (uint256) {
    return ProbabilitySuccessComponent(getAddressById(components, ProbSuccCompID)).getValue(id);
  }

  function getSource(IComponents components, uint256 id) internal view returns (uint256) {
    return IdSourceComponent(getAddressById(components, IdSourceCompID)).getValue(id);
  }

  function getStartBlock(IComponents components, uint256 id) internal view returns (uint256) {
    return BlockStartComponent(getAddressById(components, BlockStartCompID)).getValue(id);
  }

  function getTarget(IComponents components, uint256 id) internal view returns (uint256) {
    return IdTargetComponent(getAddressById(components, IdTargetCompID)).getValue(id);
  }

  function getType(IComponents components, uint256 id) internal view returns (string memory) {
    return TypeComponent(getAddressById(components, TypeCompID)).getValue(id);
  }

  // NOTE: this is just a placeholder for now
  // TODO: replace this with a random library for handling both uniform and normal distributions
  function random(uint256 seed) internal pure returns (uint256) {
    return 1e18; // 100%
  }
}
