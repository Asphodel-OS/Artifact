import { namespaceWorld } from '@latticexyz/recs';
import CreatePhaserEngine from './engine/PhaserEngine';
import { phaserConfig } from '../../config';
import { createRoomSystem } from './systems/createRoomSystem';

/**
 * The Phaser layer is responsible for rendering game objects to the screen.
 */
export async function createPhaserLayer(network: any) {
  // --- WORLD ----------------------------------------------------------------------
  const world = namespaceWorld(network.world, 'phaser');

  // --- COMPONENTS -----------------------------------------------------------------
  const components = {};

  // --- PHASER ENGINE SETUP --------------------------------------------------------

  const {
    game,
    scenes,
    dispose: disposePhaser,
  } = await CreatePhaserEngine(phaserConfig as any);
  world.registerDisposer(disposePhaser);

  // --- LAYER CONTEXT --------------------------------------------------------------
  const context = {
    world,
    components,
    network,
    game,
    scenes,
  };

  // --- SYSTEMS --------------------------------------------------------------------
  createRoomSystem(network, context);

  return context;
}
