derivation {
  name = "simple";
  builder = "/bin/bash";
  args = [ "-c" "echo hello > $out" ];
  system = "aarch64-darwin";
}