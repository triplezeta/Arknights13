import { useBackend } from '../backend';
import { Box, Button, Flex, NoticeBox, Section, Stack } from '../components';
import { Window } from '../layouts';

export const LibraryScanner = (props, context) => {
  return (
    <Window
      title="Library Scanner"
      width={350}
      height={150}>
      <BookInsert />
      <BookScanning />
    </Window>
  );
};

export const BookInsert = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    has_book,
    has_cache,
  } = data;
  if (!has_book && !has_cache) {
    return (
      <NoticeBox>
        Insert a book to scan
      </NoticeBox>
    );
  }
};

export const BookScanning = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    has_book,
    has_cache,
    book,
  } = data;
  if (!has_book && !has_cache) {
    return;
  }
  return (
    <Flex
      direction="column"
      height="100%"
      justify="flex-end">
      <Flex.Item grow>
        <Section
          height="100%"
          title={book.author}>
          {book.title}
        </Section>
      </Flex.Item>
      <Flex.Item>
        <Flex
          width="100%">
          <Flex.Item grow>
            <Button fluid
              textAlign={'center'}
              icon={'eject'}
              onClick={() => act('eject')}
              disabled={!has_book}>
              Eject Book
            </Button>
          </Flex.Item>
          <Flex.Item grow>
            <Button fluid
              textAlign={'center'}
              onClick={() => act('scan')}
              color={'good'}
              icon={'qrcode'}
              disabled={!has_book}>
              Scan Book
            </Button>
          </Flex.Item>
          <Flex.Item grow>
            <Button fluid
              textAlign={'center'}
              icon={'fire'}
              onClick={() => act('clear')}
              color={'bad'}
              disabled={!has_cache}>
              Clear Cache
            </Button>
          </Flex.Item>
        </Flex>
      </Flex.Item>
    </Flex>
  );
};
