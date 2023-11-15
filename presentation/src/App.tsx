import { defaultTheme } from "./theme/default-theme";
import {
  Deck,
  DefaultTemplate,
  Heading,
  Text,
  Slide,
  UnorderedList,
  ListItem,
} from "spectacle";

function App() {
  return (
    <>
      <Deck template={<DefaultTemplate />} theme={defaultTheme}>
        <Slide>
          <Heading>Beginner's Nix: What, Why, How?</Heading>
        </Slide>
        <Slide>
          <Text>
            Nix is a software deployment solution that enables deployments that
            are:
          </Text>
          <UnorderedList>
            <ListItem>Isolated</ListItem>
            <ListItem>Declarative</ListItem>
            <ListItem>Reproducible</ListItem>
          </UnorderedList>
          <Text>
            The implications of these properties are a game-changer. We will
            take a practical approach and explore what Nix makes possible that
            other solutions can't.
          </Text>
        </Slide>
      </Deck>
    </>
  );
}

export default App;
