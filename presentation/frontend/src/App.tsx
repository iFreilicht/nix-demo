import Terminal from "./components/Terminal";
import { defaultTheme } from "./theme/default-theme";
import {
  CodePane,
  Deck,
  DefaultTemplate,
  Markdown,
  MarkdownSlideSet,
  Notes,
  Slide,
} from "spectacle";

function App() {
  return (
    <>
      <Deck template={<DefaultTemplate />} theme={defaultTheme}>
        <Slide>
          <Markdown># Nix for all: The package manager's final form.</Markdown>
        </Slide>
        <MarkdownSlideSet>
          {`
            Nix is a

            - package manager
            - environment manager
            - build tool

            (it can do many more things, but we'll cover those three)

            ---

            and its approach to package management is

            * Isolated
            * Declarative
            * Reproducible

            The implications of these properties are a game-changer.
            We will take a practical approach and explore what Nix makes possible that other solutions can't.
            `}
        </MarkdownSlideSet>
        <Slide>
          <Terminal />
        </Slide>
        <Slide>
          <Markdown>
            {`
            ## 1. \`nix shell\`
          `}
          </Markdown>
          <Notes>
            <p>Let's say you have some version of python installed</p>
          </Notes>
          <CodePane language="command">
            {`
            # System version of python
            python3 --version
            `}
          </CodePane>
          <Notes>
            <p>
              But you would like to quickly test a feature of a newer version
            </p>
            <p>
              How and whether you can do this is different depending on your OS
              and package manager, and you're never sure what the side-effects
              will be.
            </p>
            <p> With nix, you can just try it out:</p>
          </Notes>
          <CodePane language="command">
            {`
            # Quickly run a different version
            nix shell nixpkgs#python312
            python3 --version
            `}
          </CodePane>
          <Notes>
            <p className="notes">
              The name of the command might give it away; we didn't actually
              install anything This version of python is only available in this
              shell, nowhere else. We actually created an **isolated**
              environment. If we close this shell:
            </p>
          </Notes>
          <CodePane language="command">
            {`
            exit
            python3 --version
            `}
          </CodePane>
          <Notes>
            <p>It's gone again!</p>
          </Notes>

          <Notes>
            <p>
              If you just want to run a command once, for example to test if
              your script also works with an older version of python, you can do
              it with "nix run"
            </p>
          </Notes>
          <CodePane language="command">
            nix run nixpkgs#python38 -- hello.py
          </CodePane>
          <Notes>
            <p>
              These are already useful tools to have in your belt. If you lose
              interest now and forget everything else about this talk, at least
              remember "nix shell" and "nix run", they can be a livesaver.
            </p>
          </Notes>
        </Slide>
      </Deck>
    </>
  );
}

export default App;
