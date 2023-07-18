#!/usr/bin/env bash

# Include the magic
. ./demo-magic/demo-magic.sh

# Create separate demo profile to avoid affecting user profile
DEMO_PROFILE=/tmp/demo-profile

# Restore user profile on exit
RESTORE_NIX_USER_PROFILE=$(readlink ~/.nix-profile)
function exit_hook {
    nix-env --switch-profile "$RESTORE_NIX_USER_PROFILE"
    rm -rf "$DEMO_PROFILE"
}
trap exit_hook EXIT

# Switch to demo profile only after ensuring the user profile will be restored
nix-env --switch-profile "$DEMO_PROFILE"

# Configure demo-magic
TYPE_SPEED=50

# Hide the evidence
clear

function next-step {
    p "next-step"
    echo -e "\n----\n"
}

# Fake a short nix shell session (actually calling nix shell would interrupt the demo)
function nix-shell-demo {
    p "jq --version"
    echo "bash: command not found: jq"
    p "nix shell nixpkgs#jq"
    nix profile install nixpkgs#jq
    pei "jq --version"
    p "exit"
    nix profile remove '.*' --quiet
    p "jq --version"
    echo "bash: command not found: jq"
    pe "nix shell nixpkgs#jq -c jq --version"

    next-step
}

function nix-profile-demo {
    # Show the same thing, but with nix profile
    pe "nix profile install nixpkgs#jq "
    pei "jq --version"
    pe "nix profile install nixpkgs#fd nixpkgs#asdf-vm nixpkgs#ripgrep nixpkgs#moreutils"
    pei "fd --version && asdf --version && rg --version && sponge -h"
    pe "nix profile list"
    pe "nix profile list --profile /nix/var/nix/profiles/default"
    pe "nix profile remove '.*'"

    next-step
}

function nix-profile-flake-demo {
    pe "nix shell nixpkgs#bat -c bat mytools/flake.nix"
    pe "nix profile install ./mytools"
    pei "fd --version && asdf --version && rg --version && sponge -h"
    pe "vim mytools/flake.nix"
    pe "nix profile upgrade '.*'"
    cmd # Try out the newly installed tool?
}

# nix-shell-demo
# nix-profile-demo
nix-profile-flake-demo

exit 0
