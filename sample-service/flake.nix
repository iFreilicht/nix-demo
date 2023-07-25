{
  description = "Service with TypeScript and a few python scripts.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/23.05";

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [ # _
          nodejs_20
          (yarn.override { nodejs = nodejs_20; })
          python3
          poetry
        ];
        shellHook = ''
          yarn install
          poetry env use python3
          . .venv/bin/activate
          poetry install
        '';
      };
    };
}
