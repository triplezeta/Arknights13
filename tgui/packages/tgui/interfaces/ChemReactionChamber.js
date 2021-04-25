import { map } from 'common/collections';
import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { AnimatedNumber, Box, Button, Input, LabeledList, NumberInput, Section, RoundGauge, Stack } from '../components';
import { Window } from '../layouts';
import { round, toFixed } from 'common/math';

export const ChemReactionChamber = (props, context) => {
  const { act, data } = useBackend(context);

  const [
    reagentName,
    setReagentName,
  ] = useLocalState(context, 'reagentName', '');
  const [
    reagentQuantity,
    setReagentQuantity,
  ] = useLocalState(context, 'reagentQuantity', 1);

  const {
    emptying,
    temperature,
    ph,
    targetTemp,
    isReacting,
    reagentAcidic,
    reagentAlkaline,
  } = data;
  const reagents = data.reagents || [];
  return (
    <Window
      width={290}
      height={400}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section
              title="Conditions"
              buttons={(
                <Stack>
                  <Stack.Item mt={0.3}>
                    {"Target:"}
                  </Stack.Item>
                  <Stack.Item>
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
                  </Stack.Item>
                </Stack>
              )}>
              <LabeledList>
                <LabeledList.Item label="Current Temperature">
                  <AnimatedNumber
                    value={temperature}
                    format={value => toFixed(value) + ' K'} />
                </LabeledList.Item>
                <LabeledList.Item label="pH">
                  <AnimatedNumber value={ph}>
                    {(_, value) => (
                      <RoundGauge
                        value={value}
                        minValue={0}
                        maxValue={14}
                        format={() => null}
                        left={-7.5}
                        position="absolute"
                        size={1.50}
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
                  <AnimatedNumber
                    value={ph}
                    format={value => round(value, 3)} />
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              title="Settings"
              fill
              scrollable
              buttons={(
                isReacting && (
                  <Box
                    inline
                    bold
                    color={"purple"}>
                    {"Reacting"}
                  </Box>
                ) || (
                  <Box
                    inline
                    bold
                    color={emptying ? "bad" : "good"}>
                    {emptying ? "Emptying" : "Filling"}
                  </Box>
                )
              )}>
              <Stack vertical fill>
                <Stack.Item>
                  <LabeledList>
                    <LabeledList.Item label="Acidic pH limit">
                      <NumberInput
                        value={reagentAcidic}
                        minValue={-1000}
                        maxValue={1000}
                        step={1}
                        stepPixelSize={3}
                        width="39px"
                        onDrag={(e, value) => act('acidic', {
                          target: value,
                        })} />
                    </LabeledList.Item>
                    <LabeledList.Item label="Alkaline pH limit">
                      <NumberInput
                        value={reagentAlkaline}
                        minValue={-1000}
                        maxValue={1000}
                        step={1}
                        stepPixelSize={3}
                        width="39px"
                        onDrag={(e, value) => act('alkaline', {
                          target: value,
                        })} />
                      <Box inline mr={1} />
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item>
                  <Stack fill>
                    <Stack.Item grow>
                      <Input
                        fluid
                        value=""
                        placeholder="Reagent Name"
                        onInput={(e, value) => setReagentName(value)} />
                    </Stack.Item>
                    <Stack.Item>
                      <NumberInput
                        value={reagentQuantity}
                        minValue={1}
                        maxValue={100}
                        step={1}
                        stepPixelSize={3}
                        width="39px"
                        onDrag={(e, value) => setReagentQuantity(value)} />
                      <Box inline mr={1} />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="plus"
                        onClick={() => act('add', {
                          chem: reagentName,
                          amount: reagentQuantity,
                        })} />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack vertical>
                    {reagents.map(reagent => (
                      <Stack.Item key={reagent}>
                        <Stack fill>
                          <Stack.Item mt={0.25} textColor="label">
                            {reagent.name+":"}
                          </Stack.Item>
                          <Stack.Item mt={0.25} grow>
                            {reagent.required_reagent}
                          </Stack.Item>
                          <Stack.Item>
                            <Button
                              icon="minus"
                              color="bad"
                              onClick={() => act('remove', {
                                chem: reagent,
                              })} />
                          </Stack.Item>
                        </Stack>
                      </Stack.Item>
                    ))}
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
