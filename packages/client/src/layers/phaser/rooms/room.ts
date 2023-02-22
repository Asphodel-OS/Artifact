import { PhaserScene } from '../types';
import { roomImage } from '../../../public/assets/room.png';
import { resizePicture } from '../utils/resizePicture';

const scale = resizePicture();

export function room() {
  return {
    preload: (scene: PhaserScene) => {
      scene.load.image('room', roomImage);
    },
    create: (scene: PhaserScene) => {
      scene.add
        .image(window.innerWidth / 2, window.innerHeight / 2, 'room001')
        .setScale(scale * 8.3);
    },
  };
}
