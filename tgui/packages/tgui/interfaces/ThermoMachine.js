import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, Modal, NumberInput, Section, ProgressBar } from '../components';
import { Window } from '../layouts';

export const ThermoMachine = (props, context) => {
  const { act, data } = useBackend(context);
  const pressure_error = !!data.skipping_work && (
    <Modal>
      <Box
        style={{ margin: 'auto' }}
        width="200px"
        textAlign="center"
        minHeight="39px">
        {"Port not connected or with no gas"}
      </Box>
    </Modal>
  );
  const cooling_efficiency_infos = !!data.cooling &&(
    <LabeledList.Item label="Cooling Efficiency">
      <ProgressBar
        value={data.efficiency}
        minValue={.4225}
        maxValue={1}
        ranges={{
          good: [.826, 1],
          average: [.65, .825],
          bad: [.4225, .64],
        }}>
        {Math.round(data.efficiency * 10000)/100 + " %"}
      </ProgressBar>
    </LabeledList.Item>
  );
  return (
    <Window
      width={300}
      height={350}>
      <Window.Content>
        <Section title="Status">
          {pressure_error}
          <LabeledList>
            <LabeledList.Item label="Temperature">
              <AnimatedNumber
                value={data.temperature}
                format={value => toFixed(value, 2)} />
              {' K'}
            </LabeledList.Item>
            <LabeledList.Item label="Pressure">
              <AnimatedNumber
                value={data.pressure}
                format={value => toFixed(value, 2)} />
              {' kPa'}
            </LabeledList.Item>
            <LabeledList.Item label="Mode">
              {data.cooling? 'Cooling' : 'Heating'}
            </LabeledList.Item>
            {cooling_efficiency_infos}
          </LabeledList>
        </Section>
        <Section
          title="Controls"
          buttons={(
            <Button
              icon={data.on ? 'power-off' : 'times'}
              content={data.on ? 'On' : 'Off'}
              selected={data.on}
              onClick={() => act('power')} />
          )}>
          <LabeledList>
            <LabeledList.Item label="Target Temperature">
              <NumberInput
                animated
                value={Math.round(data.target)}
                unit="K"
                width="62px"
                minValue={Math.round(data.min)}
                maxValue={Math.round(data.max)}
                step={5}
                stepPixelSize={3}
                onDrag={(e, value) => act('target', {
                  target: value,
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Presets">
              <Button
                icon="fast-backward"
                disabled={data.target === data.min}
                title="Minimum temperature"
                onClick={() => act('target', {
                  target: data.min,
                })} />
              <Button
                icon="sync"
                disabled={data.target === data.initial}
                title="Room Temperature"
                onClick={() => act('target', {
                  target: data.initial,
                })} />
              <Button
                icon="fast-forward"
                disabled={data.target === data.max}
                title="Maximum Temperature"
                onClick={() => act('target', {
                  target: data.max,
                })} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
