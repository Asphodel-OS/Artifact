import {
  EntityIndex,
  getComponentValue,
  Schema,
  Metadata,
  Component
} from '@latticexyz/recs';

export const hexToDecimal = (hex: string) => parseInt(hex, 16);

export const getCurrentRoom = (
  component: Component<Schema, Metadata, undefined>,
  entity: EntityIndex
): number => {
  const currentRoom = getComponentValue(component, entity);
  if (currentRoom) {
    const value = currentRoom.value as string;
    return hexToDecimal(value);
  }
  return 0;
};
