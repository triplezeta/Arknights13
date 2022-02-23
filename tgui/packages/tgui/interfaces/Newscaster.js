/**
 * @file
 * @author Original by ArcaneMusic (https://github.com/ArcaneMusic)
 * @author Changes Shadowh4nD/jlsnow301
 * @license MIT
 */

import { useBackend, useSharedState, useLocalState } from '../backend';
import { BountyBoardContent } from './BountyBoard';
import { UserDetails } from './Vending';
import { BlockQuote, Box, Button, Divider, Modal, Section, Stack, Tabs, TextArea } from '../components';
import { Window } from '../layouts';
import { marked } from 'marked';
import { sanitizeText } from "../sanitize";

const CENSOR_MESSAGE = "This channel has been deemed as threatening to \
the welfare of the station, and marked with a Nanotrasen D-Notice.";

export const Newscaster = (props, context) => {
  const { act, data } = useBackend(context);
  const [screenmode, setScreenmode] = useSharedState(context, 'tab_main', 1);
  const NewscasterScreen = 1;
  const BountyboardScreen = 2;
  return (
    <Window
      width={575}
      height={560}>
      <NewscasterChannelCreation />
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs fluid textAlign="center">
              <Tabs.Tab
                color="Green"
                selected={screenmode === NewscasterScreen}
                onClick={() => setScreenmode(1)}>
                Newscaster
              </Tabs.Tab>
              <Tabs.Tab
                Color="Blue"
                selected={screenmode === BountyboardScreen}
                onClick={() => setScreenmode(2)}>
                Bounty Board
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {screenmode === 1 && (
              <NewscasterContent />
            )}
            {screenmode === 2 && (
              <BountyBoardContent />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** The modal menu that contains the prompts to making new channels. */
const NewscasterChannelCreation = (props, context) => {
  const { act, data } = useBackend(context);
  const [publicmode, setPublicmode] = useLocalState(context, 'publicmode', 1);
  const {
    creating_channel,
    creating_message,
    viewing_channel,
    name,
    desc,
  } = data;
  if (!creating_channel) {
    return null;
  }
  return (
    <Modal
      textAlign="center"
      mr={1.5}>
      <Stack vertical>
        <Stack.Item>
          <Box pb={1}>
            Enter channel name Here:
          </Box>
          <TextArea
            fluid
            height="40px"
            width="240px"
            backgroundColor="black"
            textColor="white"
            maxLength={42}
            onChange={(e, name) => act('channelName', {
              channeltext: name,
            })}>
            Channel Name
          </TextArea>
        </Stack.Item>
        <Stack.Item>
          <Box pb={1}>
            Enter channel description here:
          </Box>
          <TextArea
            fluid
            height="150px"
            width="240px"
            backgroundColor="black"
            textColor="white"
            maxLength={512}
            onChange={(e, desc) => act('channelDesc', {
              channeldesc: desc,
            })}>
            Channel Description
          </TextArea>
        </Stack.Item>
        <Stack.Item>
          <Section>
            Set Channel as Public or Private
            <Box pt={1}>
              <Button
                selected={!!publicmode}
                content="Public"
                onClick={() => act(setPublicmode(true))} />
              <Button
                selected={!publicmode}
                content="Private"
                onClick={() => act(setPublicmode(false))} />
            </Box>
          </Section>
        </Stack.Item>
        <Stack.Item>
          <Box>
            <Button
              content="Submit Channel"
              onClick={() => act('createChannel', {
                publicmode: publicmode,
                viewing_channel: viewing_channel,
              })} />
            <Button
              content="Cancel"
              color="red"
              onClick={() => act('cancelChannelCreation')} />
          </Box>
        </Stack.Item>
      </Stack>
    </Modal>
  );
};

/** The modal menu that contains the prompts to making new channels. */
const NewscasterCommentCreation = (props, context) => {
  const { act, data } = useBackend(context);
  const [publicmode, setPublicmode] = useLocalState(context, 'publicmode', 1);
  const {
    creating_message,
    viewing_channel,
  } = data;
  if (!creating_message) {
    return null;
  }
  return (
    <Modal
      textAlign="center"
      mr={1.5}>
      <Stack vertical>
        <Stack.Item>
          <Box pb={1}>
            Enter comment:
          </Box>
          <TextArea
            fluid
            height="120px"
            width="240px"
            backgroundColor="black"
            textColor="white"
            maxLength={512}
            onChange={(e, comment) => act('commentBody', {
              commenttext: comment,
            })}>
            Channel Name
          </TextArea>
        </Stack.Item>
        <Stack.Item>
          <Box>
            <Button
              content={"Submit Channel"}
              onClick={() => act('createComment', {
                viewing_channel: viewing_channel,
              })} />
            <Button
              content={"Cancel"}
              color={"red"}
              onClick={() => act('cancelCommentCreation')} />
          </Box>
        </Stack.Item>
      </Stack>
    </Modal>
  );
};

export const NewscasterContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    current_channel = [],
  } = data;
  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item grow>
            <NewscasterChannelSelector />
          </Stack.Item>
          <Stack.Item grow={2}>
            <Stack fill vertical>
              <Stack.Item>
                <UserDetails />
              </Stack.Item>
              <Stack.Item grow>
                <NewscasterChannelBox
                  channelName={current_channel.name}
                  channelOwner={current_channel.owner}
                  channelDesc={current_channel.desc} />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <NewscasterChannelMessages />
      </Stack.Item>
    </Stack>
  );
};

/** The Channel Box is the basic channel information where buttons live.*/
const NewscasterChannelBox = (_, context) => {
  const { act, data } = useBackend(context);
  const {
    channelName,
    channelDesc,
    channelBlocked,
    channelAuthor,
    channelCensored,
    viewing_channel,
    security_mode,
    photo_data,
    paper,
    user,
  } = data;
  return (
    <Section fill title={channelName}>
      <Stack fill vertical>
        <Stack.Item grow>
          {channelCensored ? (
            <Section>
              <BlockQuote color="Red">
                <b>ATTENTION:</b> {CENSOR_MESSAGE}
              </BlockQuote>
            </Section>)
            : (
              <Section fill scrollable>
                <BlockQuote italic fontSize={1.2} wrap>
                  {deconvertHtmlString(channelDesc)}
                </BlockQuote>
              </Section>
            )}
        </Stack.Item>
        <Stack.Item>
          <Box>
            <Button
              icon="print"
              content="Submit Story"
              disabled={(channelBlocked && (channelAuthor !== user.name))
            || channelCensored}
              onClick={() => act('createStory', { current: viewing_channel })}
              mt={1} />
            <Button
              icon="camera"
              selected={photo_data}
              content="Select Photo"
              disabled={(channelBlocked && (channelAuthor !== user.name))
            || channelCensored}
              onClick={() => act('togglePhoto')} />
            {!!security_mode && (
              <Button
                icon="ban"
                content={"D-Notice"}
                tooltip="Censor the whole channel and it's \
                  contents as dangerous to the station. Cannot be undone."
                disabled={!security_mode}
                onClick={() => act('channelDNotice', {
                  secure: security_mode,
                  channel: viewing_channel,
                })} />
            )}
          </Box>
          <Box>
            <Button
              icon="newspaper"
              content="Print Newspaper"
              disabled={paper <= 0}
              onClick={() => act('printNewspaper')} />
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

/** Channel select is the left-hand menu where all the channels are listed. */
const NewscasterChannelSelector = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    channels = [],
    viewing_channel,
  } = data;
  return (
    <Section
      minHeight="100%"
      width={(window.innerWidth - 410) + "px"}>
      <Tabs vertical>
        {channels.map(channel => (
          <Tabs.Tab
            key={channel.name}
            pt={0.75}
            pb={0.75}
            mr={1}
            selected={viewing_channel === channel.ID}
            icon={channel.censored ? 'ban' : null}
            textColor={channel.censored ? "Red" : "white"}
            onClick={() => act('setChannel', {
              channel: channel.ID,
            })}>
            {channel.name}
          </Tabs.Tab>
        ))}
        <Tabs.Tab
          pt={0.75}
          pb={0.75}
          mr={1}
          textColor="white"
          color={"Green"}
          onClick={() => act('startCreateChannel')}>
          Create Channel [+]
        </Tabs.Tab>
      </Tabs>
    </Section>
  );
};

const processedText = value => {
  const textHtml = {
    __html: sanitizeText(marked(value, {
      breaks: true,
      smartypants: true,
      smartLists: true,
      baseUrl: 'thisshouldbreakhttp',
    })),
  };
  return textHtml;
};


/** This is where the channels comments get spangled out (tm) */
const NewscasterChannelMessages = (_, context) => {
  const { act, data } = useBackend(context);
  const {
    messages = [],
    viewing_channel,
    security_mode,
    channelCensored,
    user,
  } = data;
  if (channelCensored) {
    return (
      <Section color="Red">
        <b>ATTENTION:</b> Comments cannot be read at this time.<br />
        Thank you for your understanding, and have a secure day.
      </Section>
    );
  }
  return (
    <Section fill scrollable>
      {messages.map(message => {
        if (message.channel_num !== viewing_channel) {
          return;
        }
        return (
          <Section
            key={message.body}
            title={(
              <i>
                {!!message.censored_author && (
                  <Box textColor="Red">
                    By: [REDACTED]. <b>D-Notice Notice</b> .
                  </Box>
                )}
                {!message.censored_author && (
                  <>
                    By: {message.auth} at {message.time}
                  </>
                )}
              </i>
            )}
            buttons={(
              <>
                {!!security_mode && (
                  <Button
                    icon="comment-slash"
                    tooltip="Censor Story"
                    disabled={!security_mode}
                    onClick={() => act('storyCensor', {
                      secure: security_mode,
                      messageID: message.ID,
                    })} />
                )}
                {!!security_mode && (
                  <Button
                    icon="user-slash"
                    tooltip="Censor Author"
                    disabled={!security_mode}
                    onClick={() => act('authorCensor', {
                      secure: security_mode,
                      messageID: message.ID,
                    })} />
                )}
                <Button
                  icon="comment"
                  tooltip="Leave a Comment."
                  disabled={
                    message.censored_author
                  || message.censored_message
                  || user.name === "Unknown"
                  }
                  onClick={() => act('comment')}
                />
              </>
            )} >
            <BlockQuote
              textColor="white">
              {!!message.censored_message &&(
                <Section textColor="Red">
                  This message was deemed dangerous to the general welfare
                  of the station and therefore marked with a <b>D-Notice</b>.
                </Section>
              )}
              {!message.censored_message &&(
                <Section
                  color="label"
                  dangerouslySetInnerHTML={processedText(message.body)}
                  pl={1} />
              )}
              {message.photo !== null && !message.censored_message &&(
                <Box
                  as="img"
                  src={message.Photo} />
              )}
            </BlockQuote>
            <Divider />
          </Section>
        ); }
      )}
    </Section>
  );
};

export const deconvertHtmlString = (text) => {
  return text.replace(/&#(\d+);/g, (_, dec) => {
    return String.fromCharCode(dec);
  });
};
