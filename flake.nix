{
  description = "Demo of Nix.";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (system: 
      let
        pkgs = nixpkgs.legacyPackages.${system};
        packages = {
          inherit (pkgs)
          # Dependencies of demo-magic
          pv
          ;
        };
      in 
      {
        packages.default = pkgs.buildEnv {
          name = "nix-demo-env";
          paths = builtins.attrValues packages;
        };
      }
    );
}
