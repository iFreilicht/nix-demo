{
  description = "Demo of Nix.";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.default = pkgs.buildEnv {
          name = "nix-demo-env";
          paths = with pkgs; [ # _
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
