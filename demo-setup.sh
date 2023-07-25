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

# Reset files we edit during the demo to their starting state
git restore mytools/flake.nix

# Configure demo-magic
# TYPE_SPEED=0
PROMPT_COLOR="$(tput setab 4)$(tput setaf 15)"
RESET_STYLE="$(tput sgr0)"
TRIANGLE_COLOR="$RESET_STYLE$(tput setaf 4)"
DEMO_PROMPT="$PROMPT_COLOR \w $TRIANGLE_COLOR"" $RESET_STYLE"
