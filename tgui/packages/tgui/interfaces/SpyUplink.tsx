import { useBackend } from '../backend';
import { Window } from '../layouts';
import { BooleanLike } from 'common/react';
import { BlockQuote, Box, Dimmer, Section, Stack } from '../components';

type Bounty = {
  name: string;
  help: string;
  difficulty: string;
  reward: string;
  claimed: BooleanLike;
};

type Data = {
  bounties: Bounty[];
};

const BountyDisplay = (props: { bounty: Bounty }, context) => {
  const { bounty } = props;

  const difficult_to_color = {
    'easy': 'good',
    'medium': 'average',
    'hard': 'bad',
  };

  return (
    <Section>
      {!!bounty.claimed && (
        <Dimmer>
          <i>Claimed</i>
        </Dimmer>
      )}
      <Stack vertical ml={1}>
        <Stack.Item>
          <Box color={difficult_to_color[bounty.difficulty]}>
            {bounty.name}.
          </Box>
        </Stack.Item>
        <Stack.Item>
          <BlockQuote>{bounty.help}</BlockQuote>
        </Stack.Item>
        <Stack.Item>
          <i>Reward: {bounty.reward}</i>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const SpyUplink = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { bounties } = data;
  return (
    <Window width={450} height={600} theme={'neutral'}>
      <Window.Content>
        <Section fill title="Spy Bounties" scrollable>
          <Stack vertical fill>
            <Stack.Item>
              {bounties.map((bounty) => (
                <Stack.Item key={bounty.name} className="candystripe">
                  <BountyDisplay bounty={bounty} />
                </Stack.Item>
              ))}
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
