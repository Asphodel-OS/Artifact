// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IUint256Component as IComponents } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById } from "solecs/utils.sol";

import { IndexItemComponent, ID as IndexItemCompID } from "components/IndexItemComponent.sol";
import { IndexConsumableComponent, ID as IndexConsCompID } from "components/IndexConsumableComponent.sol";
import { IndexEquipComponent, ID as IndexEquipCompID } from "components/IndexEquipComponent.sol";
import { IsRegistryComponent, ID as IsRegCompID } from "components/IsRegistryComponent.sol";
import { AffinityComponent, ID as AffCompID } from "components/AffinityComponent.sol";
import { ClassComponent, ID as ClassCompID } from "components/ClassComponent.sol";
import { NameComponent, ID as NameCompID } from "components/NameComponent.sol";
import { TypeComponent, ID as TypeCompID } from "components/TypeComponent.sol";
import { LibStat } from "libraries/LibStat.sol";

// Registries hold shared information on individual entity instances in the world.
// This can include attribute information such as stats and effects or even prices
// commonly shared betweeen merchants. They also taxonomize entities in the world using
// the explicit Index Components (e.g. ItemIndex + EquipIndex|ConsumableIndex) to
// to identify the first two taxonomic tiers of Domain and Category and String components
// for the following tiers of Class and Type.
//
// (domain > category > class > type)
// (e.g. IndexItem, IndexEquip, ClassComponent=WIELDABLE, TypeComponent=KATANA)
// (e.g. IndexItem, IndexEquip, ClassComponent=WEARABLE, TypeComponent=TORSO)
// (e.g. IndexItem, IndexConsumable, ClassComponent=SCROLL, TypeComponent=CHAOS)
//
// NOTE: The value of Domain Indices are automatically incremented for new entries, while
// Category Indices should be explicitly defined/referenced for human-readablility. These
// tiers of taxonomization are elaborated upon for the sake of a shared language, and we
// should revisit their naming if use cases demand further tiering. Very likely we will
// have for the equipment use case. There is no requirement to use these taxonomic tiers
// exhaustively, but we should be consistent on depth within a given context.
library LibRegistryItem {
  /////////////////
  // REGISTRATION

  // Register a Wearable (equipment) registry entry. (e.g. armor, helmet, etc.)
  function registerWearable(
    IWorld world,
    IComponents components,
    uint256 equipIndex,
    string memory name,
    string memory type_,
    string memory affinity,
    uint256 level,
    uint256 hp,
    uint256 mp,
    uint256 defense,
    uint256 magicDef
  ) internal returns (uint256) {
    uint256 id = world.getUniqueEntityId();
    uint256 itemIndex = getItemCount(components) + 1;
    IsRegistryComponent(getAddressById(components, IsRegCompID)).set(id);
    IndexItemComponent(getAddressById(components, IndexItemCompID)).set(id, itemIndex);
    IndexEquipComponent(getAddressById(components, IndexEquipCompID)).set(id, equipIndex);
    AffinityComponent(getAddressById(components, AffCompID)).set(id, affinity); // check for empty strings
    ClassComponent(getAddressById(components, ClassCompID)).set(id, string("WEARABLE"));
    NameComponent(getAddressById(components, NameCompID)).set(id, name);
    TypeComponent(getAddressById(components, TypeCompID)).set(id, type_);
    if (level > 0) LibStat.setLevel(components, id, level);
    if (hp > 0) LibStat.setHP(components, id, hp);
    if (mp > 0) LibStat.setMP(components, id, mp);
    if (defense > 0) LibStat.setDefense(components, id, defense);
    if (magicDef > 0) LibStat.setMagicDef(components, id, magicDef);
    return id;
  }

  // Register a Wieldable (equipment) registry entry. (e.g. sword, axe, etc.)
  function registerWieldable(
    IWorld world,
    IComponents components,
    uint256 equipIndex,
    string memory name,
    string memory type_,
    string memory affinity,
    uint256 level,
    uint256 attack,
    uint256 magicAtt,
    uint256 range,
    uint256 speed
  ) internal returns (uint256) {
    uint256 id = world.getUniqueEntityId();
    uint256 itemIndex = getItemCount(components) + 1;
    IsRegistryComponent(getAddressById(components, IsRegCompID)).set(id);
    IndexItemComponent(getAddressById(components, IndexItemCompID)).set(id, itemIndex);
    IndexEquipComponent(getAddressById(components, IndexEquipCompID)).set(id, equipIndex);
    AffinityComponent(getAddressById(components, AffCompID)).set(id, affinity); // check for empty strings
    ClassComponent(getAddressById(components, ClassCompID)).set(id, string("WIELDABLE"));
    NameComponent(getAddressById(components, NameCompID)).set(id, name);
    TypeComponent(getAddressById(components, TypeCompID)).set(id, type_);
    if (level > 0) LibStat.setLevel(components, id, level);
    if (attack > 0) LibStat.setAttack(components, id, attack);
    if (magicAtt > 0) LibStat.setMagicAtt(components, id, magicAtt);
    if (range > 0) LibStat.setRange(components, id, range);
    if (speed > 0) LibStat.setSpeed(components, id, speed);
    return id;
  }

  // Register a Potion (consumable) registry entry. (e.g. health, mana, stat enhancement etc.)
  function registerPotion(
    IWorld world,
    IComponents components,
    uint256 consumableIndex,
    string memory name,
    uint256 hp,
    uint256 mp,
    uint256 attack,
    uint256 defense,
    uint256 magicAtt,
    uint256 magicDef,
    uint256 duration
  ) internal returns (uint256) {
    uint256 id = world.getUniqueEntityId();
    uint256 itemIndex = getItemCount(components) + 1;
    IsRegistryComponent(getAddressById(components, IsRegCompID)).set(id);
    IndexItemComponent(getAddressById(components, IndexItemCompID)).set(id, itemIndex);
    IndexConsumableComponent(getAddressById(components, IndexConsCompID)).set(id, consumableIndex);
    ClassComponent(getAddressById(components, ClassCompID)).set(id, string("POTION"));
    NameComponent(getAddressById(components, NameCompID)).set(id, name);
    if (duration > 0) LibStat.setDuration(components, id, duration);
    if (hp > 0) LibStat.setHP(components, id, hp);
    if (mp > 0) LibStat.setMP(components, id, mp);
    if (attack > 0) LibStat.setAttack(components, id, attack);
    if (defense > 0) LibStat.setDefense(components, id, defense);
    if (magicAtt > 0) LibStat.setMagicAtt(components, id, magicAtt);
    if (magicDef > 0) LibStat.setMagicDef(components, id, magicDef);
    return id;
  }

  // Register a Scroll (consumable) registry entry. (e.g. 60% +4 att upgrade)
  function registerScroll(
    IWorld world,
    IComponents components,
    uint256 consumableIndex,
    string memory name,
    string memory type_, // Normal, Chaos, etc.
    uint256 probSuccess,
    uint256 probFailure,
    uint256 hp,
    uint256 mp,
    uint256 attack,
    uint256 defense,
    uint256 magicAtt,
    uint256 magicDef
  ) internal returns (uint256) {
    uint256 id = world.getUniqueEntityId();
    uint256 itemIndex = getItemCount(components) + 1;
    IsRegistryComponent(getAddressById(components, IsRegCompID)).set(id);
    IndexItemComponent(getAddressById(components, IndexItemCompID)).set(id, itemIndex);
    IndexConsumableComponent(getAddressById(components, IndexConsCompID)).set(id, consumableIndex);
    ClassComponent(getAddressById(components, ClassCompID)).set(id, string("SCROLL"));
    NameComponent(getAddressById(components, NameCompID)).set(id, name);
    TypeComponent(getAddressById(components, TypeCompID)).set(id, type_);
    if (probSuccess > 0) LibStat.setProbability(components, id, probSuccess);
    if (probFailure > 0) LibStat.setProbabilityFail(components, id, probFailure);
    if (hp > 0) LibStat.setHP(components, id, hp);
    if (mp > 0) LibStat.setMP(components, id, mp);
    if (attack > 0) LibStat.setAttack(components, id, attack);
    if (defense > 0) LibStat.setDefense(components, id, defense);
    if (magicAtt > 0) LibStat.setMagicAtt(components, id, magicAtt);
    if (magicDef > 0) LibStat.setMagicDef(components, id, magicDef);
    return id;
  }

  /////////////////
  // CHECKERS

  function isInstance(IComponents components, uint256 id) internal view returns (bool) {
    return hasIsRegistry(components, id) && hasItemIndex(components, id);
  }

  function hasIsRegistry(IComponents components, uint256 id) internal view returns (bool) {
    return IsRegistryComponent(getAddressById(components, IsRegCompID)).has(id);
  }

  function hasConsumableIndex(IComponents components, uint256 id) internal view returns (bool) {
    return IndexConsumableComponent(getAddressById(components, IndexConsCompID)).has(id);
  }

  function hasEquipIndex(IComponents components, uint256 id) internal view returns (bool) {
    return IndexEquipComponent(getAddressById(components, IndexEquipCompID)).has(id);
  }

  function hasItemIndex(IComponents components, uint256 id) internal view returns (bool) {
    return IndexItemComponent(getAddressById(components, IndexItemCompID)).has(id);
  }

  function hasAffinity(IComponents components, uint256 id) internal view returns (bool) {
    return AffinityComponent(getAddressById(components, AffCompID)).has(id);
  }

  function hasClass(IComponents components, uint256 id) internal view returns (bool) {
    return ClassComponent(getAddressById(components, ClassCompID)).has(id);
  }

  function hasName(IComponents components, uint256 id) internal view returns (bool) {
    return NameComponent(getAddressById(components, NameCompID)).has(id);
  }

  function hasType(IComponents components, uint256 id) internal view returns (bool) {
    return TypeComponent(getAddressById(components, TypeCompID)).has(id);
  }

  /////////////////
  // GETTERS

  function getItemIndex(IComponents components, uint256 id) internal view returns (uint256) {
    return IndexItemComponent(getAddressById(components, IndexItemCompID)).getValue(id);
  }

  function getConsumableIndex(IComponents components, uint256 id) internal view returns (uint256) {
    return IndexConsumableComponent(getAddressById(components, IndexConsCompID)).getValue(id);
  }

  function getEquipIndex(IComponents components, uint256 id) internal view returns (uint256) {
    return IndexEquipComponent(getAddressById(components, IndexEquipCompID)).getValue(id);
  }

  function getAffinity(IComponents components, uint256 id) internal view returns (string memory) {
    return AffinityComponent(getAddressById(components, AffCompID)).getValue(id);
  }

  function getClass(IComponents components, uint256 id) internal view returns (string memory) {
    return ClassComponent(getAddressById(components, ClassCompID)).getValue(id);
  }

  function getName(IComponents components, uint256 id) internal view returns (string memory) {
    return NameComponent(getAddressById(components, NameCompID)).getValue(id);
  }

  function getType(IComponents components, uint256 id) internal view returns (string memory) {
    return TypeComponent(getAddressById(components, TypeCompID)).getValue(id);
  }

  /////////////////
  // QUERIES

  // get the number of item registry entries
  function getItemCount(IComponents components) internal view returns (uint256) {
    QueryFragment[] memory fragments = new QueryFragment[](2);
    fragments[0] = QueryFragment(QueryType.Has, getComponentById(components, IsRegCompID), "");
    fragments[1] = QueryFragment(QueryType.Has, getComponentById(components, IndexItemCompID), "");
    return LibQuery.query(fragments).length;
  }

  // get the registry entry by item index
  function getByItemIndex(IComponents components, uint256 itemIndex)
    internal
    view
    returns (uint256 result)
  {
    uint256[] memory results = _getAllX(components, itemIndex, 0, 0);
    if (results.length != 0) result = results[0];
  }

  // get all fungible(item) inventory entities matching filters. 0 values indicate no filter
  function _getAllX(
    IComponents components,
    uint256 itemIndex,
    uint256 equipIndex,
    uint256 consumableIndex
  ) internal view returns (uint256[] memory) {
    uint256 setFilters; // number of optional non-zero filters
    if (itemIndex != 0) setFilters++;
    if (equipIndex != 0) setFilters++;
    if (consumableIndex != 0) setFilters++;

    uint256 filterCount = 2; // number of mandatory filters
    QueryFragment[] memory fragments = new QueryFragment[](setFilters + filterCount);
    fragments[0] = QueryFragment(QueryType.Has, getComponentById(components, IsRegCompID), "");
    fragments[1] = QueryFragment(QueryType.Has, getComponentById(components, IndexItemCompID), "");

    if (itemIndex != 0) {
      fragments[filterCount++] = QueryFragment(
        QueryType.HasValue,
        getComponentById(components, IndexItemCompID),
        abi.encode(itemIndex)
      );
    }
    if (equipIndex != 0) {
      fragments[filterCount++] = QueryFragment(
        QueryType.HasValue,
        getComponentById(components, IndexEquipCompID),
        abi.encode(equipIndex)
      );
    }
    if (consumableIndex != 0) {
      fragments[filterCount++] = QueryFragment(
        QueryType.HasValue,
        getComponentById(components, IndexConsCompID),
        abi.encode(consumableIndex)
      );
    }

    return LibQuery.query(fragments);
  }
}
