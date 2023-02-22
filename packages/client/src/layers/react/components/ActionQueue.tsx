import React, { useEffect } from 'react';
import {
  getComponentEntities,
  getComponentValueStrict,
} from '@latticexyz/recs';
import { concat, map } from 'rxjs';
import { ActionStateString, ActionState } from '@latticexyz/std-client';
import { registerUIComponent } from '../engine/store';
import styled from 'styled-components';

export function registerActionQueue() {
  registerUIComponent(
    'ActionQueue',
    {
      rowStart: 50,
      rowEnd: 70,
      colStart: 82,
      colEnd: 98,
    },

    (layers) => {
      const {
        network: {
          actions: { Action },
        },
      } = layers;

      return concat([1], Action.update$).pipe(
        map(() => ({
          Action,
        }))
      );
    },

    ({ Action }) => {
      return (
        <ModalWrapper>
          <ModalContent style={{ pointerEvents: 'auto' }}>
            <Description>TX Queue:</Description>
            {[...getComponentEntities(Action)].map((e) => {
              const actionData = getComponentValueStrict(Action, e);
              const state = ActionStateString[actionData.state as ActionState];
              return (
                <Description key={`action${e}`}>
                  {Action.world.entities[e]}: {state}
                </Description>
              );
            })}
          </ModalContent>
        </ModalWrapper>
      );
    }
  );
}

const ModalWrapper = styled.div`
  display: grid;
  align-items: left;
`;

const ModalContent = styled.div`
  display: flex;
  flex-direction: column;
  background-color: white;
  border-radius: 10px;
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.3);
  padding: 20px;
  width: 99%;
  border-style: solid;
  border-width: 2px;
  border-color: black;

  overflow: scroll;
  max-height: 175px;
`;

const Description = styled.p`
  font-size: 14px;
  color: #333;
  text-align: left;
  padding: 2px;
  font-family: Pixel;
`;
