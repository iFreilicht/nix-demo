{
  description = "A scripted in-shell demo of Nix.";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        bashrc = pkgs.writeText ".bashrc" ''
          # Make prompt nice and terse
          export PS1='\e[92;1mfelix\e[0m:\e[94;1m~/\W\e[0m$ '
        '';
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

          shellHook = ''
            # Use temporary home directory to prevent programs reading config files from there
            export HOME=$TMPDIR

            # Source our own bashrc for the first invocation of `nix develop`
            source ${bashrc}

            # Ensure the bashrc will be sourced again when `nix shell` or `nix develop` are run
            ln -s ${bashrc} $TMPDIR/.bashrc

            # Hide output from nix develop
            clear
          '';
        };
      });
}
