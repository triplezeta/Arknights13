import { Component, createRef, InfernoNode, RefObject } from "inferno";
import { Button, Section, Stack } from "../../components";
import { FlexProps } from "../../components/Flex";

type TabbedMenuProps = {
  categoryEntries: [string, InfernoNode][],
  contentProps?: FlexProps,
};

export class TabbedMenu extends Component<TabbedMenuProps> {
  categoryRefs: Record<string, RefObject<HTMLDivElement>> = {};
  sectionRef: RefObject<HTMLDivElement> = createRef();

  getCategoryRef(category: string): RefObject<HTMLDivElement> {
    if (!this.categoryRefs[category]) {
      this.categoryRefs[category] = createRef();
    }

    return this.categoryRefs[category];
  }

  render() {
    return (
      <Stack vertical fill>
        <Stack.Item>
          <Stack fill px={5}>
            {this.props.categoryEntries.map(([category]) => {
              return (
                <Stack.Item key={category} grow>
                  <Button
                    align="center"
                    fontSize="1.2em"
                    fluid
                    onClick={() => {
                      const offsetTop = this.categoryRefs[category]
                        .current?.offsetTop;

                      if (!this.sectionRef.current) {
                        return;
                      }

                      this.sectionRef.current.scrollTop = offsetTop;
                    }}
                  >
                    {category}
                  </Button>
                </Stack.Item>
              );
            })}
          </Stack>
        </Stack.Item>

        <Stack.Item
          grow
          ref={this.sectionRef}
          position="relative"
          overflowY="scroll"
          {...{
            ...this.props.contentProps,

            // Otherwise, TypeScript complains about invalid prop
            className: undefined,
          }}
        >
          <Stack vertical fill px={2}>
            {this.props.categoryEntries.map(
              ([category, children]) => {
                return (
                  <Stack.Item
                    key={category}
                    ref={this.getCategoryRef(category)}
                  >
                    <Section
                      fill
                      title={category}
                    >
                      {children}
                    </Section>
                  </Stack.Item>
                );
              }
            )}
          </Stack>
        </Stack.Item>
      </Stack>
    );
  }
}
