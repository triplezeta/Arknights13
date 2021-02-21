import { round } from 'common/math';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Flex, LabeledList, NumberInput, ProgressBar, RoundGauge, Section, Table } from '../components';
import { Window } from '../layouts';
import { BeakerContents } from './common/BeakerContents';

export const ChemRecipeDebug = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    targetTemp,
    isActive,
    isFlashing,
    currentTemp,
    currentpH,
    forcepH,
    forceTemp,
    targetVol,
    targatpH,
    processing,
    processAll,
    index,
    endIndex,
    beakerSpawn,
    minTemp,
    chamberContents = [],
    activeReactions = [],
    queuedReactions = [],
  } = data;
  return (
    <Window
      width={330}
      height={450}>
      <Window.Content scrollable>
        <Section
          title="Controls"
          buttons={(
            <Flex>
              <Button
                icon={beakerSpawn ? 'power-off' : 'times'}
                selected={beakerSpawn}
                content={"Spawn beaker"}
                onClick={() => act('beakerSpawn')} />
              <Button
                icon={processAll ? 'power-off' : 'times'}
                selected={processAll}
                content={"All"}
                onClick={() => act('all')} />
            </Flex>
          )}>
          <LabeledList>
            <LabeledList.Item label="Reactions">
              <Button
                icon="plus"
                onClick={() => act('setTargetList')} />
            </LabeledList.Item>
            <LabeledList.Item label="Queued">
              {processAll && (
                <Box>All</Box>
              ) || (
                <Box>
                  {queuedReactions.length && (
                    queuedReactions.map(entry => (
                      entry.name+", "
                    ))
                  )}
                </Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Temp">
              {currentTemp}K
              <NumberInput
                width="65px"
                unit="K"
                step={10}
                stepPixelSize={3}
                value={round(targetTemp)}
                minValue={0}
                maxValue={1000}
                onDrag={(e, value) => act('temperature', {
                  target: value,
                })} />
              <Button
                icon={forceTemp ? 'power-off' : 'times'}
                selected={forceTemp}
                content={"Force"}
                onClick={() => act('forceTemp')} />
              <Button
                icon={minTemp ? 'power-off' : 'times'}
                selected={minTemp}
                content={"MinTemp"}
                onClick={() => act('minTemp')} />
            </LabeledList.Item>
            <LabeledList.Item label="Vol multi">
              <NumberInput
                width="65px"
                unit="x"
                step={1}
                stepPixelSize={3}
                value={round(targetVol)}
                minValue={1}
                maxValue={200}
                onDrag={(e, value) => act('vol', {
                  target: value,
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="pH">
              {currentpH}
              <NumberInput
                width="65px"
                step={0.1}
                stepPixelSize={3}
                value={targatpH}
                minValue={0}
                maxValue={14}
                onDrag={(e, value) => act('pH', {
                  target: value,
                })} />
              <Button
                icon={forcepH ? 'power-off' : 'times'}
                selected={forcepH}
                content={"Force"}
                onClick={() => act('forcepH')} />
            </LabeledList.Item>
            <LabeledList.Item label="Index">
              {index} of {endIndex}
            </LabeledList.Item>
            <LabeledList.Item label="Start">
              <Button
                icon={processing ? 'power-off' : 'times'}
                selected={!!processing}
                content={"Start"}
                onClick={() => act('start')} />
              <Button
                icon={processing ? 'times' : 'power-off'}
                color="red"
                content={"Stop"}
                onClick={() => act('stop')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Reactions"
          buttons={(
            <Flex>
              <Flex.Item color="label">
                <AnimatedNumber
                  value={currentpH}
                  format={value => 'pH: ' + round(value, 3)} />
              </Flex.Item>
              <Flex.Item>
                <AnimatedNumber value={currentpH}>
                  {(_, value) => (
                    <RoundGauge
                      size={1.60}
                      value={value}
                      minValue={0}
                      maxValue={14}
                      alertAfter={isFlashing}
                      content={"test"}
                      format={value => null}
                      ranges={{
                        "red": [-0.22, 1.5],
                        "orange": [1.5, 3],
                        "yellow": [3, 4.5],
                        "olive": [4.5, 5],
                        "good": [5, 6],
                        "green": [6, 8.5],
                        "teal": [8.5, 9.5],
                        "blue": [9.5, 11],
                        "purple": [11, 12.5],
                        "violet": [12.5, 14],
                      }} />
                  )}
                </AnimatedNumber>
              </Flex.Item>
            </Flex>
          )}>
          {activeReactions.length === 0 && (
            <Box color="label">
              No active reactions.
            </Box>
          ) || (
            <Table>
              <Table.Row>
                <Table.Cell bold color="label">
                  Reaction
                </Table.Cell>
                <Table.Cell bold color="label">
                  {"Reaction quality"}
                </Table.Cell>
                <Table.Cell bold color="label">
                  Target
                </Table.Cell>
              </Table.Row>
              {activeReactions && activeReactions.map(reaction => (
                <Table.Row key="reactions">
                  <Table.Cell width={'60px'} color={reaction.danger && "red"}>
                    {reaction.name}
                  </Table.Cell>
                  <Table.Cell width={'100px'} pr={'10px'}>
                    <AnimatedNumber value={reaction.quality}>
                      {(_, value) => (
                        <RoundGauge
                          size={1.30}
                          value={value}
                          minValue={0}
                          maxValue={1}
                          alertAfter={reaction.purityAlert}
                          content={"test"}
                          format={value => null}
                          ml={5}
                          ranges={{
                            "red": [0, reaction.minPure],
                            "orange": [reaction.minPure, reaction.inverse],
                            "yellow": [reaction.inverse, 0.8],
                            "green": [0.8, 1],
                          }} />
                      )}
                    </AnimatedNumber>
                  </Table.Cell>
                  <Table.Cell width={'70px'}>
                    <ProgressBar
                      value={reaction.reactedVol}
                      minValue={0}
                      maxValue={reaction.targetVol}
                      textAlign={'center'}
                      icon={reaction.overheat && "thermometer-full"}
                      width={7}
                      color={reaction.overheat ? "red" : "label"}>
                      {reaction.targetVol}u
                    </ProgressBar>
                  </Table.Cell>
                </Table.Row>
              ))}
              <Table.Row />
            </Table>
          )}
        </Section>
        <Section
          title="Chamber"
          buttons={(
            <Box>
              {isActive ? "Reacting" : "Waiting"}
            </Box>
          )} >
          {chamberContents.length &&(
            <BeakerContents
              beakerLoaded
              beakerContents={chamberContents} />
          ) || (
            <Box>
              Nothing
            </Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
