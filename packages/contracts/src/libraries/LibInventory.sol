// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IUint256Component as IComponents } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById } from "solecs/utils.sol";

import { IdHolderComponent, ID as IdHolderCompID } from "components/IdHolderComponent.sol";
import { IndexItemComponent, ID as IndexItemCompID } from "components/IndexItemComponent.sol";
import { IsFungibleComponent, ID as IsFungCompID } from "components/IsFungibleComponent.sol";
import { IsInventoryComponent, ID as IsInvCompID } from "components/IsInventoryComponent.sol";
import { BalanceComponent, ID as BalanceCompID } from "components/BalanceComponent.sol";

// handles fungible inventory instances
library LibInventory {
  /////////////////
  // INTERACTIONS

  // Create a new fungible (item) inventory instance, owned by an entity with a Holder ID
  function create(
    IWorld world,
    IComponents components,
    uint256 holderID,
    uint256 itemIndex
  ) internal returns (uint256) {
    uint256 id = world.getUniqueEntityId();
    IsInventoryComponent(getAddressById(components, IsInvCompID)).set(id);
    IsFungibleComponent(getAddressById(components, IsFungCompID)).set(id);
    IdHolderComponent(getAddressById(components, IdHolderCompID)).set(id, holderID);
    IndexItemComponent(getAddressById(components, IndexItemCompID)).set(id, itemIndex);
    BalanceComponent(getAddressById(components, BalanceCompID)).set(id, 0);
    return id;
  }

  // Transfer the specified inventory amt from=>to entity by incrementing/decrementing balances
  function transfer(
    IComponents components,
    uint256 fromID,
    uint256 toID,
    uint256 amt
  ) internal {
    dec(components, fromID, amt);
    inc(components, toID, amt);
  }

  // Increase an inventory balance by the specified amount
  function inc(
    IComponents components,
    uint256 id,
    uint256 amt
  ) internal returns (uint256) {
    uint256 bal = getBalance(components, id);
    bal += amt;
    _set(components, id, bal);
    return bal;
  }

  // Decrease an inventory balance by the specified amount
  function dec(
    IComponents components,
    uint256 id,
    uint256 amt
  ) internal returns (uint256) {
    uint256 bal = getBalance(components, id);
    require(bal >= amt, "Inventory: insufficient balance");
    bal -= amt;
    if (bal == 0) {
      del(components, id);
    } else {
      _set(components, id, bal);
    }
    return bal;
  }

  // Delete the inventory instance
  function del(IComponents components, uint256 id) internal {
    IsInventoryComponent(getAddressById(components, IsInvCompID)).remove(id);
    IdHolderComponent(getAddressById(components, IdHolderCompID)).remove(id);
    IndexItemComponent(getAddressById(components, IndexItemCompID)).remove(id);
    BalanceComponent(getAddressById(components, BalanceCompID)).remove(id);
  }

  // Set the balance of an existing inventory entity
  function _set(
    IComponents components,
    uint256 id,
    uint256 amt
  ) internal {
    BalanceComponent(getAddressById(components, BalanceCompID)).set(id, amt);
  }

  /////////////////
  // CHECKS

  // Check if the specified entity is a fungible inventory instance
  function isInstance(IComponents components, uint256 id) internal view returns (bool) {
    return
      IsInventoryComponent(getAddressById(components, IsInvCompID)).has(id) &&
      IsFungibleComponent(getAddressById(components, IsFungCompID)).has(id);
  }

  /////////////////
  // COMPONENT RETRIEVAL

  // get the balance of a fungible inventory instance. return 0 if none exists
  function getBalance(IComponents components, uint256 id) internal view returns (uint256 balance) {
    BalanceComponent balanceComp = BalanceComponent(getAddressById(components, BalanceCompID));
    if (balanceComp.has(id)) {
      balance = balanceComp.getValue(id);
    }
  }

  function getItemIndex(IComponents components, uint256 id) internal view returns (uint256) {
    return IndexItemComponent(getAddressById(components, IndexItemCompID)).getValue(id);
  }

  function getHolder(IComponents components, uint256 id) internal view returns (uint256) {
    return IdHolderComponent(getAddressById(components, IdHolderCompID)).getValue(id);
  }

  /////////////////
  // QUERIES

  // get a specific fungible(item) inventory instance. assume only one exists
  function get(
    IComponents components,
    uint256 holderID,
    uint256 itemIndex
  ) internal view returns (uint256 result) {
    uint256[] memory results = _getAllX(components, holderID, itemIndex);
    if (results.length > 0) result = results[0];
  }

  // get all fungible(item) inventory entities matching filters. 0 values indicate no filter
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
    fragments[1] = QueryFragment(QueryType.Has, getComponentById(components, IsFungCompID), "");

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
