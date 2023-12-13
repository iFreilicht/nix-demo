{
  description = "A scripted in-shell demo of Nix.";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.nix-demo-env = pkgs.mkShell {
          name = "nix-demo-env";

          packages = with pkgs; [ # _
            # Use a locked version of nix independent of the system/user-installed one
            nixVersions.nix_2_16 # TODO: Upgrade to 2_17 or 2_18 once released
            # Basic shell environment
            coreutils
            ncurses
            # Dependencies of demo-magic
            pv
            # Dependencies of the demo script itself
            figlet
            lolcat
            tree
            python39 # Older version of python to have a "system default"
          ];

          shellHook =
          # Prevent entering if we're not in the directory of this flake
          ''
            if [ ! -e "demo-root-marker" ]; then
                echo "Error: 'demo-root-marker' is not in CWD!"
                exit 1
            fi
          '' +
          # Use fake home directory. This is useful in multiple ways:
          # - programs won't read the user's actual config files
          # - config files that ensure the demo works properly (like the nix registry) are read from a controlled location
          # - the cache is persistent, which speeds up the execution of some commands
          # - the prompt shows a short but correct path, no need for faking anything
          ''
            export HOME=$PWD/fake-home
            cd $HOME
          '' +
            # Source our own bashrc for the first invocation of `nix develop`
          ''
            source .bashrc
          '' +
          # Hide output from `nix develop`
          ''
            clear
          '';
        };
      });
}
