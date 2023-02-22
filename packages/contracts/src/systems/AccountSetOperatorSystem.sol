// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";

import { LibAccount } from "libraries/LibAccount.sol";

uint256 constant ID = uint256(keccak256("system.AccountSetOperator"));

// AccountSetOperatorSystem sets the operator address of an account, identified
// by the caller's address.
contract AccountSetOperatorSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public returns (bytes memory) {
    address newOperator = abi.decode(arguments, (address));
    uint256 accountID = LibAccount.getByOwner(components, msg.sender);

    require(accountID != 0, "Account: does not exist");

    LibAccount.setOperatorAddress(components, accountID, newOperator);
    return abi.encode(accountID);
  }

  function executeTyped(address operator) public returns (bytes memory) {
    return execute(abi.encode(operator));
  }
}
