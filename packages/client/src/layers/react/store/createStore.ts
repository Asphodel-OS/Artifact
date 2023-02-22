import create from 'zustand';

export interface DataObject {
  description: string;
}

export interface RoomExits {
  up: number;
  down: number;
}

export interface VisibleDivs {
  petMint: boolean;
  petDetails: boolean;
  objectModal: boolean;
  mintProcess: boolean;
  inventory: boolean;
  chat: boolean;
  merchant: boolean;
  petList: boolean;
}

export interface StoreState {
  objectData: DataObject;
  roomExits: RoomExits;
  selectedPet: DataObject;
  visibleDivs: VisibleDivs;
}

interface StoreActions {
  setObjectData: (data: DataObject) => void;
  setRoomExits: (data: RoomExits) => void;
  setSelectedPet: (data: DataObject) => void;
  setVisibleDivs: (data: VisibleDivs) => void;
}

export const dataStore = create<StoreState & StoreActions>((set) => {
  const initialState: StoreState = {
    objectData: { description: '' },
    roomExits: { up: 0, down: 0 },
    selectedPet: { description: '' },
    visibleDivs: {
      petMint: false,
      petDetails: false,
      objectModal: false,
      mintProcess: false,
      inventory: false,
      chat: false,
      merchant: false,
      petList: false,
    },
  };

  return {
    ...initialState,
    setObjectData: (data: DataObject) =>
      set((state: StoreState) => ({ ...state, objectData: data })),
    setRoomExits: (data: RoomExits) =>
      set((state: StoreState) => ({ ...state, roomExits: data })),
    setSelectedPet: (data: DataObject) =>
      set((state: StoreState) => ({ ...state, objectData: data })),
    setVisibleDivs: (data: VisibleDivs) =>
      set((state: StoreState) => ({ ...state, visibleDivs: data })),
  };
});
