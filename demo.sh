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
    nix profile install nixpkgs#python312
    p "python3 --version"
    nix shell 'nixpkgs#python312' -c python3 --version
    # The name of the command might give it away; we didn't actually install anything
    # This version of python is only available in this shell, nowhere else.
    # We actually created an **isolated** environment.
    # If we close this shell:
    p "exit"
    nix profile remove '.*' --quiet
    # It's gone again!
    pe "python3 --version"
    # This itself is already a useful tool. If you lose interest now and forget everything
    # else about this talk, at least remember nix shell, it can be a livesaver.
    # You can also make nix shell call a command and exit immediately
    # This can be useful inside shell scripts
    pe "nix shell nixpkgs#python312 -c python3 --version"

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
    pe "nix shell nixpkgs#bat -c bat mytools/flake.nix"
    # explain what's in the flake, roughly
    # And now we can install this single flake at once, and all tools will be in our profile
    pe "nix profile install ./mytools"
    pei "fd --version && asdf --version && rg --version && sponge -h"
    # Now, we don't want to install additional tools with `install` anymore, we want to
    # update our flake instead, so that we can track what we installed. Simple enough:
    # Add cowsay, that's cute and fun
    pe "vim mytools/flake.nix"
    pe "nix profile upgrade '.*'"
    cmd # Actually type a cowsay command

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
    nix profile install nixpkgs#bat
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
    # As you can see, nix put us in a shell where not only node, yarn, python and poetry are installed, but
    # also all dependencies defined py package.json and pyproject.toml are available. This is a somewhat minimal setup,
    # both nix and poetry try to be as reproducible as possible, and so the bash shell we're in right now
    # has not sourced any of the rc files it normally would. We can back to my custom zsh config by just launching that.

    # We can now launch python and import the click module,
    # or open ts-node with `yarn exec ts-node`

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

exit 0
