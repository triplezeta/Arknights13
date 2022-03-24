import { useBackend } from '../backend';
import { Button, LabeledList, Section, Box, Modal } from '../components';
import { Window } from '../layouts';

export const TurbineComputer = (props, context) => {
  const { act, data } = useBackend(context);
  const parts_not_connected = !data.parts_linked && (
    <Modal>
      <Box
        style={{ margin: 'auto' }}
        width="200px"
        textAlign="center"
        minHeight="39px">
        {"Parts not connected, use a multitool on the core rotor before trying again"}
      </Box>
    </Modal>
  );
  return (
    <Window
      width={310}
      height={185}>
      <Window.Content>
        <Section
          title="Status"
          buttons={(
            <Button
              icon={data.active ? 'power-off' : 'times'}
              content={data.active ? 'Online' : 'Offline'}
              selected={data.active}
              disabled={!data.can_turn_off || !data.parts_linked}
              onClick={() => act('toggle_power')} />
          )}>
          {parts_not_connected}
          <LabeledList>

            <LabeledList.Item label="Turbine Integrity">
              {data.integrity}%
            </LabeledList.Item>
            <LabeledList.Item label="Turbine Speed">
              {data.rpm} RPM
            </LabeledList.Item>
            <LabeledList.Item label="Max Turbine Speed">
              {data.max_rpm} RPM
            </LabeledList.Item>
            <LabeledList.Item label="Input Temperature">
              {data.temp} K
            </LabeledList.Item>
            <LabeledList.Item label="Max Temperature">
              {data.max_temperature} K
            </LabeledList.Item>
            <LabeledList.Item label="Generated Power">
              {data.power * 4 * 0.001} kW
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
