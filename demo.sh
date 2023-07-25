#!/usr/bin/env bash

. demo-setup.sh

# Hide the evidence
clear

function heading {
    clear
    echo
    tput bold
    figlet -c -d ~/repos/figlet-fonts -w $(tput cols) -f "Roman" -k "$1" | lolcat -F 0.03 -S 30 
    tput sgr0
}

function subheading {
    pe ""
    echo
    tput bold
    figlet -d ~/repos/figlet-fonts -w $(tput cols) -f "small slant" -k "$1" | lolcat -F 0.03 -S 70
    tput sgr0
    echo
}

function next-step {
    echo -e "\n\n\n>"
    wait
}

function intro {
    heading "0. Intro"
    wait
    cat <<EOF



                    Nix is a software deployment solution that enables deployments that are:

                        * Isolated
                        * Declarative
                        * Reproducible

                    The implications of these properties are a game-changer.
                    
                    We will take a practical approach and explore what Nix makes possible that
                    other solutions can't.



EOF
    
    next-step
}

# Fake a short nix shell session (actually calling nix shell would interrupt the demo)
function nix-shell-demo {
    heading "1. nix shell"

    # Let's say you have some version of python installed
    pe "python3 --version"
    # But you would like to quickly test a feature of a newer version
    # How and whether you can do this is different depending on your OS
    # and package manager, and you're never sure what the side-effects will be.
    # With nix, you can just try it out:
    p "nix shell nixpkgs#python312"
    p "python3 --version"
    nix run 'nixpkgs#python312' -- --version
    # The name of the command might give it away; we didn't actually install anything
    # This version of python is only available in this shell, nowhere else.
    # We actually created an **isolated** environment.
    # If we close this shell:
    p "exit"
    # It's gone again!
    pe "python3 --version"
    # This itself is already a useful tool. If you lose interest now and forget everything
    # else about this talk, at least remember nix shell, it can be a livesaver.
    # You can also make nix shell call a command and exit immediately
    # This can be useful inside shell scripts
    pe "nix shell nixpkgs#python312 -c python3 --version"
    # Or, even shorter, use nix run
    pe "nix run nixpkgs#python312 -- --version"

    p "Ok cool, but what about installing something permanently?"
    next-step
}

function nix-profile-demo {
    heading "2. nix profile"

    # Installing something works almost the same as in any other package manager
    pe "nix profile install nixpkgs#jq"
    pei "jq --version"
    # And we can install multiple packages as well
    pe "nix profile install nixpkgs#fd nixpkgs#asdf-vm nixpkgs#ripgrep nixpkgs#moreutils"
    # And they will all be available, not just in this shell,
    # but every shell we launch in the future, too
    pei "fd --version && asdf --version && rg --version && sponge -h"
    p "Note that we didn't have to use sudo!"
    # Indeed, no need for sudo. This is possible because we only installed these
    # packages to our user profile, which is completely isolated from the system profile
    # TODO: Add additional user and try to execute something as them (probably has to be faked)
    pe "nix profile list"
    pe "nix profile list --profile /nix/var/nix/profiles/default"
    # And not only are profiles isolated each other, each profile is actually isolated from its
    # previous generations. So let's say you upgrade all your packages 
    p "nix profile upgrade '.*'"
    echo "upgrading 'jq' from flake 'github:NixOS/nixpkgs/023b1df882979a413a3f7e2009424db30d51a0fe' to 'github:NixOS/nixpkgs/293a68c901e9ddbca02edff9dd78522887679c31'"
    # But now one of the tools head a breaking change or is incompatible with something else you installed
    p "jq --version"
    echo "Segmentation fault (core dumped)"
    # How do you recover from this normally? Do you have backups?
    # Maybe you can grab an old version of the package from an archive?
    # With nix, the answer is a single command
    p "nix profile rollback"
    pei "jq --version"
    # This is an atomic operation, the old generation was never changed!
    # nix profile creates a new generation on every operation, so you 
    # can always roll back to any previous state if something goes wrong!
    p "This is isolated package management!"

    # Ok, so after all this excitement, let's clean up what we've done so far
    pe "nix profile remove '.*'"
    # And...
    p "Let's start with the real magic!"
    next-step
}

function nix-profile-flake-demo {
    heading "3. flakes"

    # Previously, we installed packages imperatively, but running multiple install commands
    # after eachother. This is ok, but when we want to setup our environment on a different
    # machine, or want to help a colleague get up and running, we would have
    # to remember all of them.
    # With nix, we can create a bundle of packages, called a flake, and install that instead.
    # Let's have a look:
    pe "nix run nixpkgs#bat -- mytools/flake.nix"
    # explain what's in the flake, roughly
    # And now we can install this single flake at once, and all tools will be in our profile
    pe "nix profile install ./mytools"
    pei "fd --version && asdf --version && rg --version && sponge -h"
    # Now, we don't want to install additional tools with `install` anymore, we want to
    # update our flake instead, so that we can track what we installed. Simple enough:
    # Add cowsay, that's cute and fun
    p "vim mytools/flake.nix"
    vim mytools/flake.nix -s <(./vim/animate-edit.sh ./vim/add-cowsay.vim)
    # Remember to type :wq to exit
    pe "nix profile upgrade '.*'"
    pe "cowsay 'Nix is revoluationary!'"

    p "This is declarative package management!"
    # And it's so incredibly useful. We can now put this file into a repository, and any 
    # developer would just have to run `nix profile install` once to get everything they need.
    # Even better, the developers don't have to download the files, you can just give them a URL
    p "nix profile install git+ssh://git@ssh.dev.azure.com/v3/org/project/base-tools"
    # But wait, we usually don't work in just one repository, and most probably require
    # different versions of node, python, go, java, etc. so we can't just install them into
    # the user's profile, they would clash with eachother.
    # So, let's go one step further: to nix develop, 
    nix profile remove '.*'

    next-step
}

function nix-develop-demo {
    heading "4. nix develop"
    nix profile install nixpkgs#bat nixpkgs#jq
    # nix develop allows you to set up development enivronment that are isolated from the user profile
    # as well as from eachother. Let's look at an example service for this.
    pe "cd sample-service"
    pei "tree -FCL 1 ."
    # As you can see, this service is written in node, but has some devDependencies in python for scripts
    # It also has a flake again, so let's quickly look at that.
    pe "bat flake.nix"
    # This now contains a `devShell` output, not a package, you can see a few basic packages and a shellHook
    # These things work together now when we run
    pe "nix develop"
    # Manually run ./.zsh
    # Demo continues in sample-service/zsh because `poetry shell` prevents --command|-c option from working
    # ...
    # And enter it again for the changes to take effect.
    pe "nix develop"
    # Run `yarn versions` manually
    # So now we get the expected result
    # This isolation runs deep, you can even have multiple versions of dynamically linked libraries with the same name!
    # Nix knows which one belongs to which package and ensures that they can never interfere.
    # Talking about interference, let's exit this shell again.
    # Ctrl+D to exit
    pe "node --version; yarn --version; python3 --version; poetry --version"
    # Now we're back in our clean user environment, no trace of anything from the development shell.
    # This is a good point to stop again and take a breath. You can imagine adding more tools here,
    # and this might already be enough functionality for you. A convenient and reproducible way to set
    # up user profiles and development environments. That's pretty useful.
    cd ..
}

function nix-direnv-demo {
    cd sample-service
    # The UX of develop is a little inconvenient, so let's have a small detour before we continue. If you're
    # starting to lose interest now, keep going for just one more minute, it'll be worth it!
    pe "nix profile install nixpkgs#direnv"
    p 'eval "$(direnv hook $SHELL)"'
    eval "$(direnv hook bash)"
    # TODO: Add direnv and the shell hook sourcing to the tools file and install with nix profile upgrade '.*'
    # We'll use a tool called direnv to completely automate entering and exiting the development environment.
    p "echo 'use flake' > .envrc"
    direnv revoke # Ensure we start with restricted mode
    _direnv_hook # Run hook manually, $PROMPT_COMMAND is inactive during demo-magic 
    # With it installed and the .envrc file containting "use flake", direnv will know to enter the development shell
    # whenever we enter this directory. Because this could run arbitrary code, we have to allow this first.
    pe "direnv allow"
    _direnv_hook
    # You can see that direnv ran the shellHook from our flake and modified many of our
    # environment variables. We're not in a subshell now as we were with nix develop, so
    # I didn't even have to manually specify that I wanted to launch zsh.

    pe "node --version; yarn --version; python3 --version; poetry --version"
    # Now, we have pretty much the same environment as before, except that we din't have to do anything for it
    # except enter the directory of our project. And when we leave, all the changes will be reversed.
    pe "cd .."
    _direnv_hook
    pe "node --version; yarn --version; python3 --version; poetry --version"
    # We've come quite far by now. This is already enough to allow you to use nix to boost producitviy
    # and onboarding speeds and reduce confusion and undocumented behavior

    next-step
}

function nix-build-demo {
    heading "5. nix build"
    nix profile install nixpkgs#bat nixpkgs#direnv nixpkgs#docker
    eval "$(direnv hook bash)"
    # Now we will look at an actual project, an actual react app that we want to build and deploy
    pe "cd sample-app"
    rm -f result
    rm -rf build
    _direnv_hook
    # Note how we're already in our development environment thanks to direnv.
    pe "tree -FC -I node_modules ."
    # Another flake, let's have a look!
    pe "bat --line-range :20 --line-range 52: flake.nix"
    # I've cut out some stuff we'll get to later. For now, let's look at how our devShell is defined.
    # It's much simpler now, but you'll notice that we didn't have to specify the architecture anymore
    # At the top, there's a new input; `flake-utils`. It provides a function `eachDefaultSystem`
    # that replicates my outputs for ARM and x64 linux and macOS. Windows is supported via WSL.
    pe "yarn build"
    # We're already in the dev environment, so this will work perfectly fine
    pe "tree -FC build"
    # And indeed, we get everything and can serve this with the recommended `serve` utility
    pe "yarn exec serve -s build"
    # Ok, so far so boring. But we can integrate this with nix build to make use of input-addressed caching:
    pe "bat --line-range :14 --line-range 20:35 --line-range 51: flake.nix"
    # So in addition to our devShell, we specify a package as well, called "app" it basically runs the build
    # offline in a pure environment, meaning it has no access to any system libraries or the internet, only the
    # inputs we provide, which in this case, is the current directory. The installPhase then moves the `build`
    # directory to a unique path. Let's see it in action
    pe "nix build .#app"
    # Build the output app of the flake in the current directory
    # This will create a symlink "result" that contains our app
    pe "tree -FC result"
    # Because nix knows exactly what the inputs are, it can safely deduce that the build output didn't change
    # as long as the input didn't change. So running the build again takes less than a second
    pe "nix build .#app"
    # TODO: explain mechanics of why here?

    # but we probably want to deploy this somewhere, so I also prepared a dockerImage output that puts our app
    # in a docker image and serves it with lighttpd
    pe "bat --line-range 1 --line-range 9:14 --line-range 21:22 --line-range 34: flake.nix"
    # Note that I don't specify any dependencies explicitly here. Just the fact that I'm referring to
    # the `lighttpd.confg` file, the `lighttpd` package and the `app` package is enough for them to be included.
    # If the app package wasn't built yet, it will be built recursively, until all dependencies are present. 
    pe "nix build .#dockerImage"
    # One dependency that isn't required for this build is docker itself, the layers are built by Nix itself.
    # The output is linked at result again, but now it's a OCI container archive we can load and serve with docker
    pe "docker load < result"
    pei "docker run --rm -p 8080:8080 sample-app"
    # Also note that I included lighttpd from x86_linux, a different architecture and OS above.
    # I can just do that with Nix, it doesn't care, and it means that my container image runs everywhere.
    # The implications of this are huge. CI pipelines can share artifacts deeply, meaning you only have to run
    # a build once. 
    # TODO: maybe continue? Not sure, it feels like the mechanics are underexplained right now.
}

function nix-reproducability {

    # The answer is no, and I'll show you why. Let's see what's actually inside mytools:
    pe "cd mytools"
    pei "tree ."
    # There's a lockfile next to my flake! And what does it contain?
    pe "bat -l json flake.lock"
    # An exact revision and hash of the nixpkgs package repository! Unless we run `upgrade`,
    # This file will never be changed, and we will always get the exact same versions.
    # That's why we have to define nixpkgs as an input! Any package in nixpkgs is a pure function,
    # meaning that its output depends only on the input, and if the input stays the same,
    # the output stays the same as well.
    # This is the concept that underpins the whole Nix ecosystem.
    pe "nix flake metadata"  
}

intro
nix-shell-demo
nix-profile-demo
nix-profile-flake-demo
nix-develop-demo
nix-direnv-demo
nix-build-demo

exit 0
