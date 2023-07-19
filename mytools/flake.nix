{
  description = "My Tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.05";
  };

  outputs = { self, nixpkgs }:
    let 
      pkgs = nixpkgs.legacyPackages.aarch64-darwin; 
    in
    {
      packages.aarch64-darwin.default = pkgs.buildEnv {
        name = "my-tools";
        paths = with pkgs; [
          asdf-vm
          fd
          bat
          moreutils
          ripgrep
        ];
      };
    };
}
