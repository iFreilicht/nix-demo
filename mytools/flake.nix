{
  description = "My Tools";
  outputs = { self, nixpkgs }:
    let 
      pkgs = nixpkgs.legacyPackages.aarch64-darwin; 
    in
    {
      packages.aarch64-darwin.default = pkgs.buildEnv {
        name = "my-tools";
        paths = builtins.attrValues {
          inherit (pkgs)
          asdf-vm
          fd
          moreutils
          ripgrep
          ;
        };
      };
    };
}
