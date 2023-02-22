/* eslint-disable @typescript-eslint/no-non-null-assertion */
import { defineSystem, Has, HasValue, runQuery } from '@latticexyz/recs';
import { NetworkLayer } from '../../network/types';
import { PhaserLayer, PhaserScene } from '../types';
import { getCurrentRoom } from '../utils';

export function createRoomSystem(network: NetworkLayer, phaser: PhaserLayer) {
  const {
    network: { connectedAddress },
    world,
    components: { OperatorAddress },
  } = network;

  const {
    game: {
      scene: {
        keys: { Main },
      },
    },
  } = phaser;

  const myMain = Main as PhaserScene;

  defineSystem(world, [Has(OperatorAddress)], async (update) => {
    const characterEntityNumber = Array.from(
      runQuery([HasValue(OperatorAddress, { value: connectedAddress.get() })])
    )[0];

    if (characterEntityNumber == update.entity) {
      myMain.interactiveObjects.forEach((object: any) => {
        try {
          object.removeInteractive();
          object.removeFromDisplayList();
        } catch (e) {
          // Ignore objects that have already had their interactivity removed
        }
      });
      myMain.interactiveObjects = [];

      myMain.rooms![0].create(myMain);
    }
  });
}
