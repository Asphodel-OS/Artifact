// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibString } from "solady/utils/LibString.sol";
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
    NameComponent(getAddressById(components, NameCompID)).set(id, name);
    ClassComponent(getAddressById(components, ClassCompID)).set(id, string("WEARABLE"));
    TypeComponent(getAddressById(components, TypeCompID)).set(id, type_);
    AffinityComponent(getAddressById(components, AffCompID)).set(id, affinity); // check for empty strings
    if (level > 0) LevelComponent(getAddressById(components, LevelCompID)).set(id, level);
    if (hp > 0) HPComponent(getAddressById(components, HPCompID)).set(id, hp);
    if (mp > 0) MPComponent(getAddressById(components, MPCompID)).set(id, mp);
    if (defense > 0) DefenseComponent(getAddressById(components, DefCompID)).set(id, defense);
    if (magicDef > 0) MagicDefComponent(getAddressById(components, MagDefCompID)).set(id, magicDef);
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
    NameComponent(getAddressById(components, NameCompID)).set(id, name);
    ClassComponent(getAddressById(components, ClassCompID)).set(id, string("WIELDABLE"));
    TypeComponent(getAddressById(components, TypeCompID)).set(id, type_);
    AffinityComponent(getAddressById(components, AffCompID)).set(id, affinity); // check for empty strings
    if (level > 0) LevelComponent(getAddressById(components, LevelCompID)).set(id, level);
    if (attack > 0) AttackComponent(getAddressById(components, AttCompID)).set(id, attack);
    if (magicAtt > 0) MagicAttComponent(getAddressById(components, MagAttCompID)).set(id, magicAtt);
    if (range > 0) RangeComponent(getAddressById(components, RangeCompID)).set(id, range);
    if (speed > 0) SpeedComponent(getAddressById(components, SpeedCompID)).set(id, speed);
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
    NameComponent(getAddressById(components, NameCompID)).set(id, name);
    ClassComponent(getAddressById(components, ClassCompID)).set(id, string("POTION"));
    if (duration > 0) DurationComponent(getAddressById(components, DurCompID)).set(id, duration);
    if (hp > 0) HPComponent(getAddressById(components, HPCompID)).set(id, hp);
    if (mp > 0) MPComponent(getAddressById(components, MPCompID)).set(id, mp);
    if (attack > 0) AttackComponent(getAddressById(components, AttCompID)).set(id, attack);
    if (defense > 0) DefenseComponent(getAddressById(components, DefCompID)).set(id, defense);
    if (magicAtt > 0) MagicAttComponent(getAddressById(components, MagAttCompID)).set(id, magicAtt);
    if (magicDef > 0) MagicDefComponent(getAddressById(components, MagDefCompID)).set(id, magicDef);
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
    NameComponent(getAddressById(components, NameCompID)).set(id, name);
    ClassComponent(getAddressById(components, ClassCompID)).set(id, string("SCROLL"));
    TypeComponent(getAddressById(components, TypeCompID)).set(id, type_);
    if (probSuccess > 0)
      ProbabilitySuccessComponent(getAddressById(components, ProbSuccCompID)).set(id, probSuccess);
    if (probFailure > 0)
      ProbabilityFailureComponent(getAddressById(components, ProbFailCompID)).set(id, probFailure);
    if (hp > 0) HPComponent(getAddressById(components, HPCompID)).set(id, hp);
    if (mp > 0) MPComponent(getAddressById(components, MPCompID)).set(id, mp);
    if (attack > 0) AttackComponent(getAddressById(components, AttCompID)).set(id, attack);
    if (defense > 0) DefenseComponent(getAddressById(components, DefCompID)).set(id, defense);
    if (magicAtt > 0) MagicAttComponent(getAddressById(components, MagAttCompID)).set(id, magicAtt);
    if (magicDef > 0) MagicDefComponent(getAddressById(components, MagDefCompID)).set(id, magicDef);
    return id;
  }

  /////////////////
  // COMPONENT RETRIEVAL

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

  function getAttack(IComponents components, uint256 id) internal view returns (uint256) {
    return AttackComponent(getAddressById(components, AttCompID)).getValue(id);
  }

  function getClass(IComponents components, uint256 id) internal view returns (string memory) {
    return ClassComponent(getAddressById(components, ClassCompID)).getValue(id);
  }

  function getDefense(IComponents components, uint256 id) internal view returns (uint256) {
    return DefenseComponent(getAddressById(components, DefCompID)).getValue(id);
  }

  function getDuration(IComponents components, uint256 id) internal view returns (uint256) {
    return DurationComponent(getAddressById(components, DurCompID)).getValue(id);
  }

  function getHP(IComponents components, uint256 id) internal view returns (uint256) {
    return HPComponent(getAddressById(components, HPCompID)).getValue(id);
  }

  function getMagicAtt(IComponents components, uint256 id) internal view returns (uint256) {
    return MagicAttComponent(getAddressById(components, MagAttCompID)).getValue(id);
  }

  function getMagicDef(IComponents components, uint256 id) internal view returns (uint256) {
    return MagicDefComponent(getAddressById(components, MagDefCompID)).getValue(id);
  }

  function getMP(IComponents components, uint256 id) internal view returns (uint256) {
    return MPComponent(getAddressById(components, MPCompID)).getValue(id);
  }

  function getName(IComponents components, uint256 id) internal view returns (string memory) {
    return NameComponent(getAddressById(components, NameCompID)).getValue(id);
  }

  function getProbFailure(IComponents components, uint256 id) internal view returns (uint256) {
    return ProbabilityFailureComponent(getAddressById(components, ProbFailCompID)).getValue(id);
  }

  function getProbSuccess(IComponents components, uint256 id) internal view returns (uint256) {
    return ProbabilitySuccessComponent(getAddressById(components, ProbSuccCompID)).getValue(id);
  }

  function getRange(IComponents components, uint256 id) internal view returns (uint256) {
    return RangeComponent(getAddressById(components, RangeCompID)).getValue(id);
  }

  function getSpeed(IComponents components, uint256 id) internal view returns (uint256) {
    return SpeedComponent(getAddressById(components, SpeedCompID)).getValue(id);
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
