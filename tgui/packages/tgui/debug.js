/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { subscribeToHotKey } from './hotkeys';

export const toggleKitchenSink = () => ({
  type: 'debug/toggleKitchenSink',
});

export const toggleDebugLayout = () => ({
  type: 'debug/toggleDebugLayout',
});

subscribeToHotKey('Ctrl+Alt+[187]', () => toggleKitchenSink());
subscribeToHotKey('Ctrl+Alt+[189]', () => toggleDebugLayout());
subscribeToHotKey('Ctrl+Alt+[8]', () => {
  // NOTE: We need to call this in a timeout, because we need a clean
  // stack in order for this to be a fatal error.
  setTimeout(() => {
    throw new Error(
      'OOPSIE WOOPSIE!! UwU We made a fucky wucky!! A wittle'
      + ' fucko boingo! The code monkeys at our headquarters are'
      + ' working VEWY HAWD to fix this!');
  });
});

export const useDebug = context => context.store.getState().debug;

export const debugReducer = (state = {}, action) => {
  const { type, payload } = action;
  if (type === 'debug/toggleKitchenSink') {
    return {
      ...state,
      kitchenSink: !state.kitchenSink,
    };
  }
  if (type === 'debug/toggleDebugLayout') {
    return {
      ...state,
      debugLayout: !state.debugLayout,
    };
  }
  return state;
};
