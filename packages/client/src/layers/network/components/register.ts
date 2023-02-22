import {
  defineBoolComponent,
  defineNumberComponent,
  defineStringComponent,
} from "@latticexyz/std-client";

import {
  defineLoadingStateComponent,
  defineNumberArrayComponent,
  defineStringArrayComponent,
} from "./definitions";

// define functions for registration
export function createComponents(world: any) {
  return {
    // Archetypes
    IsAccount: defineBoolComponent(world, { id: "IsAccount", metadata: { contractId: "component.is.account" } }),

    // special
    OperatorAddress: defineStringComponent(world, { id: "OperatorAddress", metadata: { contractId: "component.address.operator" } }),
    OwnerAddress: defineStringComponent(world, { id: "OwnerAddress", metadata: { contractId: "component.address.owner" } }),
    LoadingState: defineLoadingStateComponent(world),
  }
}