// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";

import { LibAccount } from "libraries/LibAccount.sol";

uint256 constant ID = uint256(keccak256("system.AccountCreate"));

// AccountCreateSystem creates an account, setting the owner address to the
// caller and the operator address as specified.
contract AccountCreateSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public returns (bytes memory) {
    address operator = abi.decode(arguments, (address));
    uint256 accountID = LibAccount.getByOwner(components, msg.sender);

    require(accountID == 0, "Account: already exists");

    accountID = LibAccount.create(world, components, operator, msg.sender);
    return abi.encode(accountID);
  }

  function executeTyped(address operator) public returns (bytes memory) {
    return execute(abi.encode(operator));
  }
}
