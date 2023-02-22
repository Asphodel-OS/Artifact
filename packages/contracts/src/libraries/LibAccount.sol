// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IUint256Component as IComponents } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById } from "solecs/utils.sol";

import { AddressOwnerComponent, ID as AddrOwnerCompID } from "components/AddressOwnerComponent.sol";
import { AddressOperatorComponent, ID as AddrOpCompID } from "components/AddressOperatorComponent.sol";
import { IsAccountComponent, ID as IsAccCompID } from "components/IsAccountComponent.sol";

library LibAccount {
  /////////////////
  // INTERACTIONS

  // Create an account
  function create(
    IWorld world,
    IComponents components,
    address owner,
    address operator
  ) internal returns (uint256) {
    uint256 id = world.getUniqueEntityId();
    IsAccountComponent(getAddressById(components, IsAccCompID)).set(id);
    AddressOwnerComponent(getAddressById(components, AddrOwnerCompID)).set(id, owner);
    AddressOperatorComponent(getAddressById(components, AddrOpCompID)).set(id, operator);
    return id;
  }

  /////////////////
  // COMPONENT SETTERS

  function setOperatorAddress(
    IComponents components,
    uint256 id,
    address addr
  ) internal returns (uint256) {
    AddressOperatorComponent(getAddressById(components, AddrOpCompID)).set(id, addr);
    return id;
  }

  /////////////////
  // COMPONENT GETTERS

  // Get the address controlling this account's operator.
  function getOperatorAddress(IComponents components, uint256 id) internal view returns (address) {
    return AddressOperatorComponent(getAddressById(components, AddrOpCompID)).getValue(id);
  }

  // Get the address that owns this account.
  function getOwnerAddress(IComponents components, uint256 id) internal view returns (address) {
    return AddressOwnerComponent(getAddressById(components, AddrOwnerCompID)).getValue(id);
  }

  /////////////////
  // QUERIES

  // Get an account entity by operator address. Assume only 1.
  function getByOperator(IComponents components, address operator)
    internal
    view
    returns (uint256 result)
  {
    uint256[] memory results = _getAllX(components, address(0), operator);
    if (results.length > 0) {
      result = results[0];
    }
  }

  // Get an account entity by the owner's address. Assume only 1.
  function getByOwner(IComponents components, address owner)
    internal
    view
    returns (uint256 result)
  {
    uint256[] memory results = _getAllX(components, owner, address(0));
    if (results.length > 0) {
      result = results[0];
    }
  }

  // Get all accounts matching the specified filters.
  function _getAllX(
    IComponents components,
    address owner,
    address operator
  ) internal view returns (uint256[] memory) {
    uint256 numFilters;
    if (owner != address(0)) numFilters++;
    if (operator != address(0)) numFilters++;

    QueryFragment[] memory fragments = new QueryFragment[](numFilters + 1);
    fragments[0] = QueryFragment(QueryType.Has, getComponentById(components, IsAccCompID), "");

    uint256 filterCount;
    if (owner != address(0)) {
      fragments[++filterCount] = QueryFragment(
        QueryType.HasValue,
        getComponentById(components, AddrOwnerCompID),
        abi.encode(owner)
      );
    }
    if (operator != address(0)) {
      fragments[++filterCount] = QueryFragment(
        QueryType.HasValue,
        getComponentById(components, AddrOpCompID),
        abi.encode(operator)
      );
    }

    return LibQuery.query(fragments);
  }
}
