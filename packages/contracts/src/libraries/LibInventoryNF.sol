// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IUint256Component as IComponents } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById } from "solecs/utils.sol";

import { IdHolderComponent, ID as IdHolderCompID } from "components/IdHolderComponent.sol";
import { IndexItemComponent, ID as IndexItemCompID } from "components/IndexItemComponent.sol";
import { IsInventoryComponent, ID as IsInvCompID } from "components/IsInventoryComponent.sol";
import { IsNonFungibleComponent, ID as IsNonFungCompID } from "components/IsNonFungibleComponent.sol";

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

    // TODO: copy over the details from the registry. no variance for now
    return id;
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
    uint256 numFilters;
    if (holderID != 0) numFilters++;
    if (itemIndex != 0) numFilters++;

    QueryFragment[] memory fragments = new QueryFragment[](numFilters + 2);
    fragments[0] = QueryFragment(QueryType.Has, getComponentById(components, IsInvCompID), "");
    fragments[1] = QueryFragment(QueryType.Has, getComponentById(components, IsNonFungCompID), "");

    uint256 filterCount;
    if (holderID != 0) {
      fragments[++filterCount] = QueryFragment(
        QueryType.HasValue,
        getComponentById(components, IdHolderCompID),
        abi.encode(holderID)
      );
    }
    if (itemIndex != 0) {
      fragments[++filterCount] = QueryFragment(
        QueryType.HasValue,
        getComponentById(components, IndexItemCompID),
        abi.encode(itemIndex)
      );
    }

    return LibQuery.query(fragments);
  }
}
