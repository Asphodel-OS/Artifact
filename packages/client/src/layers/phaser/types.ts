import { defineScaleConfig, defineScene } from '@latticexyz/phaserx';
import { createPhaserLayer } from './createPhaserLayer';

export type TPhaserConfig = {
  parent: string;
  pixelArt: boolean;
  physics: {
    default: string;
    arcade: {
      debug: boolean;
      gravity: {
        y: number;
      };
    };
  };
  scene: [ReturnType<typeof defineScene>];
  title: string;
  scale: ReturnType<typeof defineScaleConfig>;
};

export type PhaserLayer = Awaited<ReturnType<typeof createPhaserLayer>>;

export interface Room {
  preload?: (scene: Phaser.Scene) => void;
  create: (scene: Phaser.Scene) => void;
  update?: (scene: Phaser.Scene) => void;
}

export interface PhaserScene extends Phaser.Scene {
  rooms?: Room[];
  gmusic?: any;
  interactiveObjects?: any;
  inputKeys?: any;
}
