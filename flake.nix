{
  description = "Tauri Javascript App";

  inputs = {
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, }:
    utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          yarn
        ];
      };
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
