import { BigNumberish } from "ethers";

export function createPlayerAPI(systems: any) {
  /////////////////
  // ACCOUNT

  // @dev creates an account for the calling EOA
  // @param operatorAddress  address of the operator EOA
  function createAccount(operatorAddress: BigNumberish) {
    return systems["system.AccountCreate"].executeTyped(operatorAddress);
  }

  // @dev sets the operator address of an account. should be called by Owner EOA
  // @param operatorAddress  address of the operator EOA
  function setAccountOperator(operatorAddress: BigNumberish) {
    return systems["system.AccountSetOperator"].executeTyped(operatorAddress);
  }

  return {
    account: {
      create: createAccount,
      setOperator: setAccountOperator,
    }
  };
}
