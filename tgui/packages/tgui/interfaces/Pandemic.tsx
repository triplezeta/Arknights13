import { useBackend, useSharedState } from '../backend';
import { Box, Button, Collapsible, Input, LabeledList, NoticeBox, ProgressBar, Section, Stack, Tabs, Tooltip } from '../components';
import { Window } from '../layouts';

type PandemicContext = {
  beaker?: Beaker;
  blood?: Blood;
  has_beaker: number;
  has_blood: number;
  is_ready: number;
  resistances?: Resistance[];
  viruses?: Virus[];
};

type Beaker = {
  volume: number;
  capacity: number;
};

type Blood = {
  dna: string;
  type: string;
};

type Resistance = {
  id: string;
  name: string;
};

type Virus = {
  name: string;
  can_rename: number;
  is_adv: number;
  symptoms: Symptom[];
  resistance: number;
  stealth: number;
  stage_speed: number;
  transmission: number;
  index: number;
  agent: string;
  description: string;
  spread: string;
  cure: string;
};

type VirusInfoProps = {
  virus: Virus;
};

type Symptom = {
  name: string;
  desc: string;
  stealth: number;
  resistance: number;
  stage_speed: number;
  transmission: number;
  level: number;
  neutered: number;
  threshold_desc: Threshold[];
};

type SymptomDisplayProps = {
  symptoms: Symptom[];
};

type Threshold = {
  label: string;
  descr: string;
};

type ThresholdDisplayProps = {
  thresholds: Threshold[];
};

export const Pandemic = (_, context) => {
  const { data } = useBackend<PandemicContext>(context);
  const { has_beaker, has_blood } = data;
  return (
    <Window width={650} height={500}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <BeakerDisplay />
          </Stack.Item>
          {!!has_beaker && !!has_blood && (
            <Stack.Item grow>
              <SpecimenDisplay />
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Displays loaded container info, if it exists */
const BeakerDisplay = (_, context) => {
  const { act, data } = useBackend<PandemicContext>(context);
  const { has_beaker, beaker, has_blood } = data;
  const cant_empty = !has_beaker || !beaker?.volume;

  return (
    <Section
      title="Beaker"
      buttons={
        <>
          <Button
            icon="times"
            content="Empty and Eject"
            color="bad"
            disabled={cant_empty}
            onClick={() => act('empty_eject_beaker')}
          />
          <Button
            icon="trash"
            content="Empty"
            disabled={cant_empty}
            onClick={() => act('empty_beaker')}
          />
          <Button
            icon="eject"
            content="Eject"
            disabled={!has_beaker}
            onClick={() => act('eject_beaker')}
          />
        </>
      }>
      {has_beaker ? (
        beaker?.volume ? (
          has_blood ? (
            <Stack vertical>
              <Stack.Item>
                <BeakerInfoDisplay />
              </Stack.Item>
              <Stack.Item>
                <AntibodyInfoDisplay />
              </Stack.Item>
            </Stack>
          ) : (
            <NoticeBox>No blood detected</NoticeBox>
          )
        ) : (
          <NoticeBox>Beaker is empty</NoticeBox>
        )
      ) : (
        <NoticeBox>No beaker loaded</NoticeBox>
      )}
    </Section>
  );
};

/** Displays info about the blood type, beaker capacity - volume */
const BeakerInfoDisplay = (_, context) => {
  const { data } = useBackend<PandemicContext>(context);
  const { beaker, blood } = data;
  if (!beaker || !blood) {
    return <NoticeBox>No beaker loaded</NoticeBox>;
  }

  return (
    <Stack>
      <Stack.Item grow={2}>
        <LabeledList>
          <LabeledList.Item label="DNA">
            {blood.dna.replace(/^\w/, (c) => c.toUpperCase())}
          </LabeledList.Item>
          <LabeledList.Item label="Type">
            {blood.type.replace(/^\w/, (c) => c.toUpperCase())}
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
      <Stack.Item grow={2}>
        <LabeledList>
          <LabeledList.Item label="Container">
            <ProgressBar
              color="darkred"
              value={beaker.volume}
              minValue={0}
              maxValue={beaker.capacity}
              ranges={{
                'good': [beaker.capacity * 0.85, beaker.capacity],
                'average': [beaker.capacity * 0.25, beaker.capacity * 0.85],
                'bad': [0, beaker.capacity * 0.25],
              }}
            />
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
    </Stack>
  );
};

/** If antibodies are present, returns buttons to create vaccines */
const AntibodyInfoDisplay = (_, context) => {
  const { act, data } = useBackend<PandemicContext>(context);
  const { is_ready, resistances } = data;
  if (!resistances) {
    return <NoticeBox>Nothing detected</NoticeBox>;
  }

  return (
    <LabeledList>
      <LabeledList.Item label="Antibodies">
        {!resistances.length
          ? 'None'
          : resistances.map((resistance) => {
            return (
              <Button
                key={resistance.name}
                icon="eye-dropper"
                disabled={!is_ready}
                tooltip="Creates a vaccine bottle."
                onClick={() =>
                  act('create_vaccine_bottle', {
                    index: resistance.id,
                  })}>
                {`${resistance.name}`}
              </Button>
            );
          })}
      </LabeledList.Item>
    </LabeledList>
  );
};

/** Displays info for the loaded blood, if any */
const SpecimenDisplay = (_, context) => {
  const { act, data } = useBackend<PandemicContext>(context);
  const [tab, setTab] = useSharedState(context, 'tab', 0);
  const { is_ready, viruses } = data;
  if (!viruses?.length) {
    return <NoticeBox>No viruses detected</NoticeBox>;
  }
  const virus = viruses[tab];
  return (
    <Section
      fill
      scrollable
      title="Specimen"
      buttons={
        <Stack>
          {
            // Tabs if there's more viruses
            viruses.length > 1 && (
              <Stack.Item>
                <Tabs>
                  {viruses.map((virus, index) => {
                    return (
                      <Tabs.Tab
                        selected={tab === index}
                        onClick={() => setTab(index)}
                        key={virus.name}>
                        {virus.name}
                      </Tabs.Tab>
                    );
                  })}
                </Tabs>
              </Stack.Item>
            )
          }
          <Stack.Item>
            <Button
              icon="flask"
              content="Create culture bottle"
              disabled={!is_ready}
              onClick={() =>
                act('create_culture_bottle', {
                  index: virus.index,
                })}
            />
          </Stack.Item>
        </Stack>
      }>
      <Stack fill vertical>
        <Stack.Item>
          <VirusInfoDisplay virus={virus} />
        </Stack.Item>
        <Stack.Item>
          <SymptomInfoDisplay symptoms={virus.symptoms} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

/** Displays info about the virus.
 * Note: Players are only getting one of these from DM,
 * but the functionality is here to display more than one.
 */
const VirusInfoDisplay = (props: VirusInfoProps, context) => {
  const { act } = useBackend<PandemicContext>(context);
  const { virus } = props;

  return (
    <Stack fill>
      <Stack.Item grow={3}>
        <LabeledList>
          <LabeledList.Item label="Name">
            {virus.can_rename ? (
              <Input
                value={virus.name}
                onChange={(e, value) =>
                  act('rename_disease', {
                    index: virus.index,
                    name: value,
                  })}
              />
            ) : (
              <Box color="bad">{virus.name}</Box>
            )}
          </LabeledList.Item>
          <LabeledList.Item label="Description">
            {virus.description}
          </LabeledList.Item>
          <LabeledList.Item label="Agent">
            {virus.agent.replace(/^\w/, (c) => c.toUpperCase())}
          </LabeledList.Item>
          <LabeledList.Item label="Spread">{virus.spread}</LabeledList.Item>
          <LabeledList.Item label="Possible Cure">
            {virus.cure}
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
      {virus.is_adv && (
        <>
          <Stack.Divider />
          <Stack.Item grow={1}>
            <Section title="Statistics">
              <LabeledList>
                <Tooltip content="Decides the cure complexity.">
                  <LabeledList.Item
                    color={GetColor(virus.resistance)}
                    label="Resistance">
                    {virus.resistance}
                  </LabeledList.Item>
                </Tooltip>
                <Tooltip content="Symptomic progression.">
                  <LabeledList.Item
                    color={GetColor(virus.stage_speed)}
                    label="Stage speed">
                    {virus.stage_speed}
                  </LabeledList.Item>
                </Tooltip>
                <Tooltip content="Detection difficulty from medical equipment.">
                  <LabeledList.Item
                    color={GetColor(virus.stealth)}
                    label="Stealth">
                    {virus.stealth}
                  </LabeledList.Item>
                </Tooltip>
                <Tooltip content="Decides the spread type.">
                  <LabeledList.Item
                    color={GetColor(virus.transmission)}
                    label="Transmissibility">
                    {virus.transmission}
                  </LabeledList.Item>
                </Tooltip>
              </LabeledList>
            </Section>
          </Stack.Item>
        </>
      )}
    </Stack>
  );
};

/** Similar to the virus info display.
 * Returns info about symptoms as collapsibles.
 */
const SymptomInfoDisplay = (props: SymptomDisplayProps) => {
  const { symptoms } = props;

  return !symptoms.length ? (
    <NoticeBox>No symptoms detected.</NoticeBox>
  ) : (
    <Section fill title="Symptoms">
      {symptoms.map((symptom) => {
        return (
          <Collapsible key={symptom.name} title={symptom.name}>
            <Stack fill>
              <Stack.Item grow={3}>
                {symptom.desc}
                <ThresholdDisplay thresholds={symptom.threshold_desc} />
              </Stack.Item>
              <Stack.Divider />
              <Stack.Item grow={1}>
                <Section title="Modifiers">
                  <LabeledList>
                    <Tooltip content="Rarity of the symptom.">
                      <LabeledList.Item
                        color={GetColor(symptom.level)}
                        label="Level">
                        {symptom.level}
                      </LabeledList.Item>
                    </Tooltip>
                    <Tooltip content="Decides the cure complexity.">
                      <LabeledList.Item
                        color={GetColor(symptom.resistance)}
                        label="Resistance">
                        {symptom.resistance}
                      </LabeledList.Item>
                    </Tooltip>
                    <Tooltip content="Symptomic progression.">
                      <LabeledList.Item
                        color={GetColor(symptom.stage_speed)}
                        label="Stage Speed">
                        {symptom.stage_speed}
                      </LabeledList.Item>
                    </Tooltip>
                    <Tooltip content="Detection difficulty from medical equipment.">
                      <LabeledList.Item
                        color={GetColor(symptom.stealth)}
                        label="Stealth">
                        {symptom.stealth}
                      </LabeledList.Item>
                    </Tooltip>
                    <Tooltip content="Decides the spread type.">
                      <LabeledList.Item
                        color={GetColor(symptom.transmission)}
                        label="Transmission">
                        {symptom.transmission}
                      </LabeledList.Item>
                    </Tooltip>
                  </LabeledList>
                </Section>
              </Stack.Item>
            </Stack>
          </Collapsible>
        );
      })}
    </Section>
  );
};

/** Displays threshold data */
const ThresholdDisplay = (props: ThresholdDisplayProps) => {
  const { thresholds } = props;
  let convertedThresholds: Threshold[] = [];
  // Converts obj of obj => array of thresholds
  // I'm sure there's a more succinct way to do this
  Object.entries(thresholds).map((label, value) => {
    return convertedThresholds.push({
      label: label[0],
      descr: label[1].toString(),
    });
  });

  return (
    <Section mt={1} title="Thresholds">
      {!convertedThresholds.length ? (
        <NoticeBox>None</NoticeBox>
      ) : (
        <LabeledList>
          {convertedThresholds.map((threshold) => {
            return (
              <LabeledList.Item key={threshold.label} label={threshold.label}>
                {threshold.descr}
              </LabeledList.Item>
            );
          })}
        </LabeledList>
      )}
    </Section>
  );
};

/** Gives a color gradient based on the severity of the symptom. */
const GetColor = (severity: number) => {
  if (severity <= -10) {
    return 'blue';
  } else if (severity <= -5) {
    return 'darkturquoise';
  } else if (severity <= 0) {
    return 'green';
  } else if (severity <= 7) {
    return 'yellow';
  } else if (severity <= 13) {
    return 'orange';
  } else {
    return 'bad';
  }
};
