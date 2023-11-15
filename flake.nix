{
  description = "Presentation of Nix functionality and concepts.";

  # As mdx-deck is a defunct project, we need to use an old version of nodejs, otherwise it doesn't work
  # This commit contains nodejs 16.6.2. See https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package=nodejs
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/c8e344196154514112c938f2814e809b1ca82da1";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nodejs
          ];
        };
      });
}
