/* eslint-disable @typescript-eslint/no-non-null-assertion */
import { defineScene } from '@latticexyz/phaserx';
import { room } from '../rooms/';
import { PhaserScene, Room } from '../types';


export function defineMainScene() {
  return {
    ['Main']: defineScene({
      key: 'Main',
      preload: (scene: PhaserScene) => {
        scene.rooms = [room()];

        scene.interactiveObjects = [];

        // scene.load.audio('m_1', room1Music);

        scene.rooms?.forEach((room: Room) => {
          if (room == undefined) return;
          if (room.preload) room.preload!(scene);
        });
      },
      create: (scene: PhaserScene) => {
        scene.sound.pauseOnBlur = false;

        scene.rooms![0].create(scene);
      },
    }),
  };
}
