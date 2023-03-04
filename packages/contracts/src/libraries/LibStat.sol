// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IUint256Component, IUint256Component as IComponents } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById, getComponentById } from "solecs/utils.sol";

import { AttackComponent, ID as AttCompID } from "components/AttackComponent.sol";
import { DefenseComponent, ID as DefCompID } from "components/DefenseComponent.sol";
import { DurationComponent, ID as DurCompID } from "components/DurationComponent.sol";
import { HPComponent, ID as HPCompID } from "components/HPComponent.sol";
import { LevelComponent, ID as LevelCompID } from "components/LevelComponent.sol";
import { MagicAttComponent, ID as MagAttCompID } from "components/MagicAttComponent.sol";
import { MagicDefComponent, ID as MagDefCompID } from "components/MagicDefComponent.sol";
import { MPComponent, ID as MPCompID } from "components/MPComponent.sol";
import { ProbabilityFailComponent, ID as ProbFailCompID } from "components/ProbabilityFailComponent.sol";
import { ProbabilityComponent, ID as ProbCompID } from "components/ProbabilityComponent.sol";
import { RangeComponent, ID as RangeCompID } from "components/RangeComponent.sol";
import { SpeedComponent, ID as SpeedCompID } from "components/SpeedComponent.sol";

// LibStat manages the retrieval and update of stats. This library differs from
// others in the sense that it does not manage a single entity type, but rather
// any entity that can have stats. Only handles uint256 components.
library LibStat {
  /////////////////
  // INTERACTIONS

  // Copy the set stats from one entity to another.
  function copy(
    IComponents components,
    uint256 fromID,
    uint256 toID
  ) internal {
    uint256[] memory componentIDs = getComponentsSet(components, fromID);
    for (uint256 i = 0; i < componentIDs.length; i++) {
      uint256 val = IUint256Component(getAddressById(components, componentIDs[i])).getValue(fromID);
      IUint256Component(getAddressById(components, componentIDs[i])).set(toID, val);
    }
  }

  // Wipe all set stats from an entity.
  function wipe(IComponents components, uint256 id) internal {
    uint256[] memory componentIDs = getComponentsSet(components, id);
    for (uint256 i = 0; i < componentIDs.length; i++) {
      getComponentById(components, componentIDs[i]).remove(id);
    }
  }

  /////////////////
  // CHECKERS

  function hasAttack(IComponents components, uint256 id) internal view returns (bool) {
    return AttackComponent(getAddressById(components, AttCompID)).has(id);
  }

  function hasDefense(IComponents components, uint256 id) internal view returns (bool) {
    return DefenseComponent(getAddressById(components, DefCompID)).has(id);
  }

  function hasDuration(IComponents components, uint256 id) internal view returns (bool) {
    return DurationComponent(getAddressById(components, DurCompID)).has(id);
  }

  function hasHP(IComponents components, uint256 id) internal view returns (bool) {
    return HPComponent(getAddressById(components, HPCompID)).has(id);
  }

  function hasLevel(IComponents components, uint256 id) internal view returns (bool) {
    return LevelComponent(getAddressById(components, LevelCompID)).has(id);
  }

  function hasMagicAtt(IComponents components, uint256 id) internal view returns (bool) {
    return MagicAttComponent(getAddressById(components, MagAttCompID)).has(id);
  }

  function hasMagicDef(IComponents components, uint256 id) internal view returns (bool) {
    return MagicDefComponent(getAddressById(components, MagDefCompID)).has(id);
  }

  function hasMP(IComponents components, uint256 id) internal view returns (bool) {
    return MPComponent(getAddressById(components, MPCompID)).has(id);
  }

  function hasProbability(IComponents components, uint256 id) internal view returns (bool) {
    return ProbabilityComponent(getAddressById(components, ProbCompID)).has(id);
  }

  function hasProbabilityFail(IComponents components, uint256 id) internal view returns (bool) {
    return ProbabilityFailComponent(getAddressById(components, ProbFailCompID)).has(id);
  }

  function hasRange(IComponents components, uint256 id) internal view returns (bool) {
    return RangeComponent(getAddressById(components, RangeCompID)).has(id);
  }

  function hasSpeed(IComponents components, uint256 id) internal view returns (bool) {
    return SpeedComponent(getAddressById(components, SpeedCompID)).has(id);
  }

  /////////////////
  // GETTERS

  // Get all the component IDs of an entity's set stats
  function getComponentsSet(IComponents components, uint256 id)
    internal
    view
    returns (uint256[] memory)
  {
    uint256 statCount;
    if (hasHP(components, id)) statCount++;
    if (hasMP(components, id)) statCount++;
    if (hasDefense(components, id)) statCount++;
    if (hasAttack(components, id)) statCount++;
    if (hasMagicAtt(components, id)) statCount++;
    if (hasMagicDef(components, id)) statCount++;
    if (hasRange(components, id)) statCount++;
    if (hasSpeed(components, id)) statCount++;
    if (hasDuration(components, id)) statCount++;
    if (hasProbability(components, id)) statCount++;
    if (hasProbabilityFail(components, id)) statCount++;

    uint256 i;
    uint256[] memory statComponents = new uint256[](statCount);
    if (hasHP(components, id)) statComponents[i++] = HPCompID;
    if (hasMP(components, id)) statComponents[i++] = MPCompID;
    if (hasAttack(components, id)) statComponents[i++] = AttCompID;
    if (hasDefense(components, id)) statComponents[i++] = DefCompID;
    if (hasMagicAtt(components, id)) statComponents[i++] = MagAttCompID;
    if (hasMagicDef(components, id)) statComponents[i++] = MagDefCompID;
    if (hasRange(components, id)) statComponents[i++] = RangeCompID;
    if (hasSpeed(components, id)) statComponents[i++] = SpeedCompID;
    if (hasDuration(components, id)) statComponents[i++] = DurCompID;
    if (hasProbability(components, id)) statComponents[i++] = ProbCompID;
    if (hasProbabilityFail(components, id)) statComponents[i++] = ProbFailCompID;
    return statComponents;
  }

  function getAttack(IComponents components, uint256 id) internal view returns (uint256) {
    return AttackComponent(getAddressById(components, AttCompID)).getValue(id);
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

  function getLevel(IComponents components, uint256 id) internal view returns (uint256) {
    return LevelComponent(getAddressById(components, LevelCompID)).getValue(id);
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

  function getProbability(IComponents components, uint256 id) internal view returns (uint256) {
    return ProbabilityComponent(getAddressById(components, ProbCompID)).getValue(id);
  }

  function getProbabilityFail(IComponents components, uint256 id) internal view returns (uint256) {
    return ProbabilityFailComponent(getAddressById(components, ProbFailCompID)).getValue(id);
  }

  function getRange(IComponents components, uint256 id) internal view returns (uint256) {
    return RangeComponent(getAddressById(components, RangeCompID)).getValue(id);
  }

  function getSpeed(IComponents components, uint256 id) internal view returns (uint256) {
    return SpeedComponent(getAddressById(components, SpeedCompID)).getValue(id);
  }

  /////////////////
  // SETTERS

  function setAttack(
    IComponents components,
    uint256 id,
    uint256 value
  ) internal {
    AttackComponent(getAddressById(components, AttCompID)).set(id, value);
  }

  function setDefense(
    IComponents components,
    uint256 id,
    uint256 value
  ) internal {
    DefenseComponent(getAddressById(components, DefCompID)).set(id, value);
  }

  function setDuration(
    IComponents components,
    uint256 id,
    uint256 value
  ) internal {
    DurationComponent(getAddressById(components, DurCompID)).set(id, value);
  }

  function setHP(
    IComponents components,
    uint256 id,
    uint256 value
  ) internal {
    HPComponent(getAddressById(components, HPCompID)).set(id, value);
  }

  function setLevel(
    IComponents components,
    uint256 id,
    uint256 value
  ) internal {
    LevelComponent(getAddressById(components, LevelCompID)).set(id, value);
  }

  function setMagicAtt(
    IComponents components,
    uint256 id,
    uint256 value
  ) internal {
    MagicAttComponent(getAddressById(components, MagAttCompID)).set(id, value);
  }

  function setMagicDef(
    IComponents components,
    uint256 id,
    uint256 value
  ) internal {
    MagicDefComponent(getAddressById(components, MagDefCompID)).set(id, value);
  }

  function setMP(
    IComponents components,
    uint256 id,
    uint256 value
  ) internal {
    MPComponent(getAddressById(components, MPCompID)).set(id, value);
  }

  function setProbability(
    IComponents components,
    uint256 id,
    uint256 value
  ) internal {
    ProbabilityComponent(getAddressById(components, ProbCompID)).set(id, value);
  }

  function setProbabilityFail(
    IComponents components,
    uint256 id,
    uint256 value
  ) internal {
    ProbabilityFailComponent(getAddressById(components, ProbFailCompID)).set(id, value);
  }

  function setRange(
    IComponents components,
    uint256 id,
    uint256 value
  ) internal {
    RangeComponent(getAddressById(components, RangeCompID)).set(id, value);
  }

  function setSpeed(
    IComponents components,
    uint256 id,
    uint256 value
  ) internal {
    SpeedComponent(getAddressById(components, SpeedCompID)).set(id, value);
  }
}
