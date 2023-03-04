// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IUint256Component as IComponents } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById } from "solecs/utils.sol";

import { IdHolderComponent, ID as IdHolderCompID } from "components/IdHolderComponent.sol";
import { IndexEquipComponent, ID as IndexEquipCompID } from "components/IndexEquipComponent.sol";
import { IndexItemComponent, ID as IndexItemCompID } from "components/IndexItemComponent.sol";
import { IsInventoryComponent, ID as IsInvCompID } from "components/IsInventoryComponent.sol";
import { IsNonFungibleComponent, ID as IsNonFungCompID } from "components/IsNonFungibleComponent.sol";
import { AffinityComponent, ID as AffCompID } from "components/AffinityComponent.sol";
import { AttackComponent, ID as AttCompID } from "components/AttackComponent.sol";
import { ClassComponent, ID as ClassCompID } from "components/ClassComponent.sol";
import { DefenseComponent, ID as DefCompID } from "components/DefenseComponent.sol";
import { DurationComponent, ID as DurCompID } from "components/DurationComponent.sol";
import { HPComponent, ID as HPCompID } from "components/HPComponent.sol";
import { LevelComponent, ID as LevelCompID } from "components/LevelComponent.sol";
import { MagicAttComponent, ID as MagAttCompID } from "components/MagicAttComponent.sol";
import { MagicDefComponent, ID as MagDefCompID } from "components/MagicDefComponent.sol";
import { MPComponent, ID as MPCompID } from "components/MPComponent.sol";
import { NameComponent, ID as NameCompID } from "components/NameComponent.sol";
import { ProbabilitySuccessComponent, ID as ProbSuccCompID } from "components/ProbabilitySuccessComponent.sol";
import { ProbabilityFailureComponent, ID as ProbFailCompID } from "components/ProbabilityFailureComponent.sol";
import { RangeComponent, ID as RangeCompID } from "components/RangeComponent.sol";
import { SpeedComponent, ID as SpeedCompID } from "components/SpeedComponent.sol";
import { TypeComponent, ID as TypeCompID } from "components/TypeComponent.sol";
import { LibRegistryItem } from "libraries/LibRegistryItem.sol";

// handles nonfungible inventory instances
library LibInventoryNF {
  /////////////////
  // INTERACTIONS

  // Create a new non-fungible (item) inventory instance with a specified holder and item instance
  function create(
    IWorld world,
    IComponents components,
    uint256 holderID,
    uint256 itemIndex
  ) internal returns (uint256) {
    uint256 id = world.getUniqueEntityId();
    IsInventoryComponent(getAddressById(components, IsInvCompID)).set(id);
    IsNonFungibleComponent(getAddressById(components, IsNonFungCompID)).set(id);
    IdHolderComponent(getAddressById(components, IdHolderCompID)).set(id, holderID);
    IndexItemComponent(getAddressById(components, IndexItemCompID)).set(id, itemIndex);

    // TODO: copy over the details from the registry. no variance in stats for now
    return id;
  }

  // Delete the inventory instance
  function del(IComponents components, uint256 id) internal {
    getComponentById(components, IsInvCompID).remove(id);
    getComponentById(components, IsNonFungCompID).remove(id);
    getComponentById(components, IdHolderCompID).remove(id);
    getComponentById(components, IndexItemCompID).remove(id);

    // TODO: detect stats that are set and delete them
  }

  // Transfer the specified NF inventory instance by updating the holder
  function transfer(
    IComponents components,
    uint256 id,
    uint256 newHolderID
  ) internal {
    IdHolderComponent(getAddressById(components, IdHolderCompID)).set(id, newHolderID);
  }

  /////////////////
  // CHECKS

  // Check if the specified entity is a non-fungible inventory instance
  function isInstance(IComponents components, uint256 id) internal view returns (bool) {
    return
      IsInventoryComponent(getAddressById(components, IsInvCompID)).has(id) &&
      IsNonFungibleComponent(getAddressById(components, IsNonFungCompID)).has(id);
  }

  /////////////////
  // COMPONENT RETRIEVAL

  function getItemIndex(IComponents components, uint256 id) internal view returns (uint256) {
    return IndexItemComponent(getAddressById(components, IndexItemCompID)).getValue(id);
  }

  function getHolder(IComponents components, uint256 id) internal view returns (uint256) {
    return IdHolderComponent(getAddressById(components, IdHolderCompID)).getValue(id);
  }

  /////////////////
  // QUERIES

  // get a specific non-fungible(item) inventory instance
  // NOTE: not so useful as we can't just assume a single instances
  function get(
    IComponents components,
    uint256 holderID,
    uint256 itemIndex
  ) internal view returns (uint256 result) {
    uint256[] memory results = _getAllX(components, holderID, itemIndex);
    if (results.length > 0) result = results[0];
  }

  // get all non-fungible(item) inventory entities matching filters. 0 values indicate no filter
  function _getAllX(
    IComponents components,
    uint256 holderID,
    uint256 itemIndex
  ) internal view returns (uint256[] memory) {
    uint256 setFilters; // number of optional non-zero filters
    if (holderID != 0) setFilters++;
    if (itemIndex != 0) setFilters++;

    uint256 filterCount = 2; // number of mandatory filters
    QueryFragment[] memory fragments = new QueryFragment[](setFilters + filterCount);
    fragments[0] = QueryFragment(QueryType.Has, getComponentById(components, IsInvCompID), "");
    fragments[1] = QueryFragment(QueryType.Has, getComponentById(components, IsNonFungCompID), "");

    if (holderID != 0) {
      fragments[filterCount++] = QueryFragment(
        QueryType.HasValue,
        getComponentById(components, IdHolderCompID),
        abi.encode(holderID)
      );
    }
    if (itemIndex != 0) {
      fragments[filterCount++] = QueryFragment(
        QueryType.HasValue,
        getComponentById(components, IndexItemCompID),
        abi.encode(itemIndex)
      );
    }

    return LibQuery.query(fragments);
  }
}
