import { defineScaleConfig } from '@latticexyz/phaserx';
import { SetupContractConfig } from "@latticexyz/std-client";
import { Wallet } from "ethers";
import { defineMainScene } from './layers/phaser/scenes/MainScene';

const params = new URLSearchParams(window.location.search);

export const networkConfig: SetupContractConfig = {
  clock: {
    period: 1000,
    initialTime: 0,
    syncInterval: 5000,
  },
  provider: {
    jsonRpcUrl: params.get("rpc") ?? "http://localhost:8545",
    wsRpcUrl: params.get("wsRpc") ?? "ws://localhost:8545",
    chainId: Number(params.get("chainId")) || 31337,
  },
  privateKey: Wallet.createRandom().privateKey,
  chainId: Number(params.get("chainId")) || 31337,
  snapshotServiceUrl: params.get("snapshot") ?? undefined,
  initialBlockNumber: Number(params.get("initialBlockNumber")) || 0,
  worldAddress: params.get("worldAddress")!,
  devMode: params.get("dev") === "true",
};


export const phaserConfig = {
  parent: 'phaser-game',
  pixelArt: true,
  physics: {
    default: 'arcade',
    arcade: { debug: false, gravity: { y: 0 } },
  },
  scene: [defineMainScene().Main],
  title: 'Cantodel',
  scale: defineScaleConfig({
    parent: 'phaser-game',
    width: 544,
    height: 288,
  }),
};