import Terminal from "./components/Terminal";
import { defaultTheme } from "./theme/default-theme";
import {
  Appear,
  CodePane,
  Deck,
  DefaultTemplate,
  Markdown,
  MarkdownSlideSet,
  Notes,
  Slide,
} from "spectacle";

const rarr = <kbd>⇨</kbd>;

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
          <Markdown>
            {`
            ## 1. \`nix shell\` and \`nix run\`

            *Ephemeral* package management, *isolated* between *sessions*
            `}
          </Markdown>
        </Slide>
        <Slide>
          <Terminal
            commands={[
              "python3 --version",
              "nix shell nixpkgs#python312",
              "python3 --version",
              "exit",
              "python3 --version",
              "nix run nixpkgs#python38 -- hello.py",
            ]}
          />
          <Notes>
            <p>Let's say you have some version of python installed</p>
            {rarr}
            <p>
              But you would like to quickly test a feature of a newer version
            </p>
            <p>
              How and whether you can do this is different depending on your OS
              and package manager, and you're never sure what the side-effects
              will be.
            </p>
            <p> With nix, you can just try it out:</p>
            {rarr}
            {rarr}
            <p>
              The name of the command might give it away; we didn't actually
              install anything This version of python is only available in this
              shell, nowhere else. We actually created an **isolated**
              environment. If we close this shell:
            </p>
            {rarr}
            {rarr}
            <p>It's gone again!</p>
            <p>
              If you just want to run a command once, for example to test if
              your script also works with an older version of python, you can do
              it with "nix run"
            </p>
            {rarr}
            <p>
              These are already useful tools to have in your belt. If you lose
              interest now and forget everything else about this talk, at least
              remember "nix shell" and "nix run", they can be a livesaver.
            </p>
            <p>
              But actually, don't lose interest yet. I'll show you some useful
              tricks and important concepts that will be very valuable when
              using these tools, but also for understanding Nix as a whole.
            </p>
          </Notes>
        </Slide>
        <Slide>
          <Appear>
            <CodePane language={"bash"}>
              {`
              nix shell nixpkgs#python312
            `}
            </CodePane>
          </Appear>
          <Appear>
            <CodePane language={"bash"}>
              {`
              nix run https://github.com/NixOS/nixpkgs/archive/refs/heads/master.zip#python38
              nix run github:NixOS/nixpkgs#python38
              nix run nixpkgs#python38
            `}
            </CodePane>
          </Appear>
          <Appear>
            <Terminal
              commands={[
                "nix run github:eza-community/eza -- -l",
                "cargo --version",
              ]}
              rows={13}
            />
          </Appear>
          <Notes>
            <p>
              First off, I'm sure you've noticed the odd "nixpkgs#package"
              syntax, right?
            </p>
            {rarr}
            <p>
              No other package manager requires you to type out the name of the
              package repository your accessing, so why would Nix? Well, this is
              actually a URL, `nixpkgs` is just a shortcut to the official
              package repository.
            </p>
            {rarr}
            <p>
              You can use any URL to a tarball or zip archive (as long as they
              contain the files nix expects), no matter if it's via https, ssh
              or a local disk, and just install directly from that. For common
              cases we have special protocol names like `github:`, and for
              integral parts of the Nix ecosystem, aliases are used.
            </p>
            <p>
              So, if you created a piece of software and want people to use it,
              you don't need to get it packaged in a distro, you don't need to
              document build instructions, tell people to install your language
              specific package manager and some required libraries first, create
              releases or anything like that. Any user can run your software
              with a single command:
            </p>
            {rarr}
            <p>
              All dependencies are installed in the exact versions you specify
              alongside it. Eza is written in Rust, but I don't even have it
              installed.
            </p>
            {rarr}
            <p>
              We'll look later at what files you need to create for this to
              work, but I think you can see how powerful this is.
            </p>
          </Notes>
        </Slide>
        <Slide>
          <Terminal
            commands={[
              "nix shell nixpkgs#jq nixpkgs#nodejs nixpkgs#pipenv",
              "jq --version && node --version && pipenv --version",
              "exit",
              "nix shell nixpkgs#{jq,nodejs,pipenv}",
              "jq --version && node --version && pipenv --version",
            ]}
          ></Terminal>
          <Notes>
            <p>
              There's another detail you should learn before we move on. You can
              enter a shell with multiple packages at once:
            </p>
            {rarr}
            {rarr}
            {rarr}
            <p>
              But typing `nixpkgs` every time is annoying. You can instead type:
            </p>
            {rarr}
            {rarr}
            <p>
              This is not a Nix feature, but a feature from bash (or zsh) called
              brace-expansion. Remember this syntax, you'll see it a few more
              times in this talk.
            </p>
            <p>
              Alright, so we can run any program without installing it, enter
              temporary environments containing any libraries or programs we
              want, but this seems somewhat limiting, right? How can we install
              packages permanently?
            </p>
          </Notes>
        </Slide>
        <Slide>
          <Markdown>
            {`
            ## 2. \`nix profile\`

            *Persistent* package management, *isolated* between *users*
            `}
          </Markdown>
          <Appear>
            <Terminal
              commands={[
                "nix profile install nixpkgs#jq",
                "jq --version",
                "nix profile install nixpkgs#{fd,asdf-vm,ripgrep,moreutils}",
                "fd --version && asdf --version && rg --version && sponge -h",
              ]}
              rows={16}
            ></Terminal>
          </Appear>
          <Notes>
            <p>
              Installing something works almost the same as in any other package
              manager.
            </p>
            {rarr}
            {rarr}
            <p>
              And we can quickly install multiple packages as well with the
              trick I've shown you before
            </p>
            {rarr}
            <p>
              And they will all be available, not just in this shell, but every
              shell we launch in the future, too
            </p>
            {rarr}
            <p>
              But are you noticing something about these commands compared to
              most other package managers? Yup, we didn't have to use sudo!
            </p>
          </Notes>
        </Slide>
      </Deck>
    </>
  );
}

export default App;
