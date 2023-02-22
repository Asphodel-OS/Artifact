// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "std-contracts/test/MudTest.t.sol";

// Libraries
import "libraries/LibAccount.sol";

// Components
import { AddressOperatorComponent, ID as AddressOperatorComponentID } from "components/AddressOperatorComponent.sol";
import { AddressOwnerComponent, ID as AddressOwnerComponentID } from "components/AddressOwnerComponent.sol";
import { IsAccountComponent, ID as IsAccountComponentID } from "components/IsAccountComponent.sol";

// Systems
import { AccountCreateSystem, ID as AccountCreateSystemID } from "systems/AccountCreateSystem.sol";
import { AccountSetOperatorSystem, ID as AccountSetOperatorSystemID } from "systems/AccountSetOperatorSystem.sol";

abstract contract TestSetupImports is MudTest {
// Components vars
AddressOperatorComponent _AddressOperatorComponent;
AddressOwnerComponent _AddressOwnerComponent;
IsAccountComponent _IsAccountComponent;

// System vars
AccountCreateSystem _AccountCreateSystem;
AccountSetOperatorSystem _AccountSetOperatorSystem;

function setUp() public virtual override {
super.setUp();

_AddressOperatorComponent = AddressOperatorComponent(component(AddressOperatorComponentID));
_AddressOwnerComponent = AddressOwnerComponent(component(AddressOwnerComponentID));
_IsAccountComponent = IsAccountComponent(component(IsAccountComponentID));

_AccountCreateSystem = AccountCreateSystem(system(AccountCreateSystemID));
_AccountSetOperatorSystem = AccountSetOperatorSystem(system(AccountSetOperatorSystemID));
}
}