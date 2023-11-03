{
  description = "Service with TypeScript and a few python scripts.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        name = "sample-app";
      in {

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ yarn ];
          shellHook = "yarn install";
        };

        packages = {
          app = pkgs.mkYarnPackage {
            inherit name;
            src = ./.;
            buildPhase = ''
              export HOME=$(mktemp -d)
              export DISABLE_ESLINT_PLUGIN="true"
              yarn --offline build
            '';
            installPhase = ''
              mv deps/${name}/build $out
            '';
            doDist = false;
          };

          dockerImage = pkgs.dockerTools.buildLayeredImage (let
            linuxPkgs = nixpkgs.legacyPackages.x86_64-linux;
            lighttpd = linuxPkgs.lighttpd;
            config-file = pkgs.writeTextFile {
              name = "lighttpd.conf";
              text = with builtins;
                replaceStrings [ "./result" ]
                [ "${self.packages.${system}.app}" ] (readFile ./lighttpd.conf);
            };
          in {
            inherit name;
            tag = "latest";
            config.Cmd =
              [ "${lighttpd}/bin/lighttpd" "-D" "-f" "${config-file}" ];
          });
        };
      });
}
