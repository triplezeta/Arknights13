import { Window } from './layouts';

const routingError = (type, name) => () => {
  return (
    <Window resizable>
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

export const getRoutedComponent = state => {
  if (process.env.NODE_ENV !== 'production') {
    // Show a kitchen sink
    if (state.showKitchenSink) {
      const { KitchenSink } = require('./interfaces/KitchenSink');
      return KitchenSink;
    }
  }
  const name = state.config?.interface;
  let esModule;
  try {
    esModule = require(`./interfaces/${name}.js`);
  }
  catch (err) {
    if (err.code === 'MODULE_NOT_FOUND') {
      return routingError('notFound', name);
    }
    throw err;
  }
  const Component = esModule[name];
  if (!Component) {
    return routingError('missingExport', name);
  }
  return Component;
};

// const ROUTES = {
//   launchpad_console: {
//     component: () => LaunchpadConsole,
//     scrollable: true,
//   },
//   launchpad_remote: {
//     component: () => LaunchpadRemote,
//     scrollable: false,
//     theme: 'syndicate',
//   },
//   mech_bay_power_console: {
//     component: () => MechBayPowerConsole,
//     scrollable: false,
//   },
//   mining_vendor: {
//     component: () => MiningVendor,
//     scrollable: true,
//   },
//   mint: {
//     component: () => Mint,
//     scrollable: false,
//   },
//   malfunction_module_picker: {
//     component: () => MalfunctionModulePicker,
//     scrollable: true,
//     theme: 'malfunction',
//   },
//   mulebot: {
//     component: () => Mule,
//     scrollable: false,
//   },
//   nanite_chamber_control: {
//     component: () => NaniteChamberControl,
//     scrollable: true,
//   },
//   nanite_cloud_control: {
//     component: () => NaniteCloudControl,
//     scrollable: true,
//   },
//   nanite_program_hub: {
//     component: () => NaniteProgramHub,
//     scrollable: true,
//   },
//   nanite_programmer: {
//     component: () => NaniteProgrammer,
//     scrollable: true,
//   },
//   nanite_remote: {
//     component: () => NaniteRemote,
//     scrollable: true,
//   },
//   notificationpanel: {
//     component: () => NotificationPreferences,
//     scrollable: true,
//   },
//   ntnet_relay: {
//     component: () => NtnetRelay,
//     scrollable: false,
//   },
//   ntos_atmos: {
//     component: () => NtosAtmos,
//     wrapper: () => NtosWrapper,
//     scrollable: true,
//     theme: 'ntos',
//   },
//   ntos_arcade: {
//     component: () => NtosArcade,
//     wrapper: () => NtosWrapper,
//     scrollable: false,
//     theme: 'ntos',
//   },
//   ntos_card: {
//     component: () => NtosCard,
//     wrapper: () => NtosWrapper,
//     scrollable: true,
//     theme: 'ntos',
//   },
//   ntos_configuration: {
//     component: () => NtosConfiguration,
//     wrapper: () => NtosWrapper,
//     scrollable: true,
//     theme: 'ntos',
//   },
//   ntos_crew_manifest: {
//     component: () => NtosCrewManifest,
//     wrapper: () => NtosWrapper,
//     scrollable: true,
//     theme: 'ntos',
//   },
//   ntos_cyborg_monitor: {
//     component: () => NtosCyborgRemoteMonitor,
//     wrapper: () => NtosWrapper,
//     scrollable: true,
//     theme: 'ntos',
//   },
//   ntos_job_manager: {
//     component: () => NtosJobManager,
//     wrapper: () => NtosWrapper,
//     scrollable: true,
//     theme: 'ntos',
//   },
// };
