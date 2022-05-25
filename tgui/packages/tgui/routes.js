/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { selectBackend } from './backend';
import { Icon, Section, Stack } from './components';
import { selectDebug } from './debug/selectors';
import { Window } from './layouts';
import { AntagInfo } from './interfaces/AntagInfo';
import { Atmos } from './interfaces/Atmos';
import { Chemistry } from './interfaces/Chemistry';
import { NtOS } from './interfaces/NtOS';

const requireInterface = require.context('./interfaces');

const routingError = (type, name) => () => {
  return (
    <Window>
      <Window.Content scrollable>
        {type === 'notFound' && (
          <div>Interface <b>{name}</b> was not found.</div>
        )}
        {type === 'missingExport' && (
          <div>Interface <b>{name}</b> is missing an export.</div>
        )}
      </Window.Content>
    </Window>
  );
};

const SuspendedWindow = () => {
  return (
    <Window>
      <Window.Content scrollable />
    </Window>
  );
};

const RefreshingWindow = () => {

  return (
    <Window title="Loading">
      <Window.Content>
        <Section fill>
          <Stack align="center" fill justify="center" vertical>
            <Stack.Item>
              <Icon color="blue" name="toolbox" spin size={4} />
            </Stack.Item>
            <Stack.Item>
              Please wait...
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

export const getRoutedComponent = store => {
  const state = store.getState();
  const { suspended, config } = selectBackend(state);
  if (suspended) {
    return SuspendedWindow;
  }
  if (config.refreshing) {
    return RefreshingWindow;
  }
  if (process.env.NODE_ENV !== 'production') {
    const debug = selectDebug(state);
    // Show a kitchen sink
    if (debug.kitchenSink) {
      return require('./debug').KitchenSink;
    }
  }
  const name = config?.interface;
  const interfacePathBuilders = [
    name => `./${name}.tsx`,
    name => `./${name}.js`,
    name => `./${name}/index.tsx`,
    name => `./${name}/index.js`,
    name => checkBundle(name),
  ];
  let esModule;
  while (!esModule && interfacePathBuilders.length > 0) {
    const interfacePathBuilder = interfacePathBuilders.shift();
    const interfacePath = interfacePathBuilder(name);
    try {
      esModule = requireInterface(interfacePath);
    }
    catch (err) {
      if (err.code !== 'MODULE_NOT_FOUND') {
        throw err;
      }
    }
  }
  if (!esModule) {
    return routingError('notFound', name);
  }
  const Component = esModule[name];
  if (!Component) {
    return routingError('missingExport', name);
  }
  return Component;
};

/** Checks bundled interfaces for the respective file */
const checkBundle = (name) => {
  return AntagInfo[name]
  || Atmos[name]
  || Chemistry[name]
  || NtOS[name]
  || null;
};
