{
  description = "A scripted in-shell demo of Nix.";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.nix-demo-env = pkgs.buildEnv {
          name = "nix-demo-env";
          paths = with pkgs; [ # _
            # Use a locked version of nix independent of the system/user-installed one
            nixVersions.nix_2_16 # TODO: Upgrade to 2_17 or 2_18 once released
            # Dependencies of demo-magic
            pv
            # Dependencies of the demo script itself
            figlet
            lolcat
            tree
          ];
        };
      });
}
