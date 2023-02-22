import { registerActionQueue } from './ActionQueue';
import { registerLoadingState } from './LoadingState';

export function registerRawComponents() {
  registerActionQueue();
  registerLoadingState();
}

export function registerDataComponents() {
}
