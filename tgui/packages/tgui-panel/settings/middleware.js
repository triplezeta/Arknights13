import { storage } from 'common/storage';
import { sendMessage } from 'tgui/backend';
import { loadSettings } from './actions';
import { selectSettings } from './selectors';

export const sendChangeTheme = name => sendMessage({
  type: 'changeTheme',
  payload: { name },
});

export const settingsMiddleware = store => {
  let initialized = false;
  return next => action => {
    const { type, payload } = action;
    if (!initialized) {
      next(action);
      initialized = true;
      const settings = storage.get('panel-settings');
      if (settings) {
        // Set client theme
        const { theme } = settings;
        if (theme) {
          sendChangeTheme(theme);
        }
        store.dispatch(loadSettings(settings));
      }
      return;
    }
    if (type === 'settings/update') {
      // Set client theme
      const { theme } = payload;
      if (theme) {
        sendChangeTheme(theme);
      }
      // Pass action to get an updated state
      next(action);
      // Save settings to the web storage
      storage.set('panel-settings', selectSettings(store.getState()));
      return;
    }
    return next(action);
  };
};
