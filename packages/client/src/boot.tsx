/* eslint-disable prefer-const */
import React from 'react';
import { Wallet } from 'ethers';
import ReactDOM from 'react-dom/client';
import {
  getComponentValue,
  removeComponent,
  setComponent,
} from '@latticexyz/recs';

import {
  registerRawComponents as registerRawComponentsImport,
  registerDataComponents as registerDataComponentsImport,
} from './layers/react/components';
import { Engine as EngineImport } from './layers/react/engine/Engine';
import { createNetworkLayer as createNetworkLayerImport } from './layers/network/createNetworkLayer';
import { createPhaserLayer as createPhaserLayerImport } from './layers/phaser/createPhaserLayer';
import { Layers } from './types';
import { Time } from './utils/time';

let createNetworkLayer = createNetworkLayerImport;
let createPhaserLayer = createPhaserLayerImport;
let registerRawComponents = registerRawComponentsImport;
let registerDataComponents = registerDataComponentsImport;
let Engine = EngineImport;

async function bootGame() {
  const layers: Partial<Layers> = {};
  let initialBoot = true;

  async function rebootGame(): Promise<Layers> {
    mountReact.current(false);

    // LOCAL CONFIG
    const params = new URLSearchParams(window.location.search);
    const worldAddress = params.get('worldAddress');
    const chainIdString = params.get('chainId');
    const jsonRpc = params.get('rpc') || undefined;
    const wsRpc = params.get('wsRpc') || undefined; // || (jsonRpc && jsonRpc.replace("http", "ws"));
    const checkpointUrl = params.get('checkpoint') || undefined;
    const snapshotUrl = params.get('snapshotUrl') || '';
    const initialBlockNumberString = params.get('initialBlockNumber');
    const initialBlockNumber = initialBlockNumberString
      ? parseInt(initialBlockNumberString)
      : 0;

    const wallet = new Wallet(
      '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80'
    );
    localStorage.setItem('operatorPrivateKey', wallet.privateKey);
    localStorage.setItem('operatorPublicKey', wallet.publicKey);
    let relayServiceUrl = '', faucetServiceUrl = '';

    // create 
    let networkLayerConfig;
    if (worldAddress && wallet && chainIdString && jsonRpc) {
      networkLayerConfig = {
        worldAddress,
        privateKey: wallet.privateKey,
        chainId: parseInt(chainIdString),
        jsonRpc,
        wsRpc,
        checkpointUrl,
        devMode: true,
        initialBlockNumber,
        faucetServiceUrl,
        relayServiceUrl,
        snapshotUrl,
      };
    } else {
      throw new Error('Invalid config');
    }

    if (!layers.network)
      layers.network = await createNetworkLayer(networkLayerConfig);
    if (!layers.phaser) layers.phaser = await createPhaserLayer(layers.network);

    Time.time.setPacemaker((setTimestamp) => {
      layers.phaser?.game.events.on('poststep', (time: number) => {
        setTimestamp(time);
      });
    });

    if (document.querySelectorAll('#phaser-game canvas').length > 1) {
      console.log('Detected two canvas elements, full reload');
    }

    if (initialBoot) {
      initialBoot = false;
      layers.network.startSync();
    }

    mountReact.current(true);

    return layers as Layers;
  }

  await rebootGame();

  const ecs = {
    setComponent,
    removeComponent,
    getComponentValue,
  };

  (window as any).layers = layers;
  (window as any).ecs = ecs;
  (window as any).time = Time.time;

  console.log('booted');

  return { layers, ecs };
}

const mountReact: { current: (mount: boolean) => void } = {
  current: () => void 0,
};
const setLayers: { current: (layers: Layers) => void } = {
  current: () => void 0,
};

function bootReact() {
  const rootElement = document.getElementById('react-root');
  if (!rootElement) return console.warn('React root not found');

  const root = ReactDOM.createRoot(rootElement);

  function renderEngine() {
    root.render(<Engine setLayers={setLayers} mountReact={mountReact} />);
  }

  renderEngine();
  registerRawComponents();
}

export async function boot() {
  bootReact();
  const game = await bootGame();
  setLayers.current(game.layers as Layers);
  registerDataComponents();
}
