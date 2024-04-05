{
  lib,
  writeShellApplication,
  jq,
}:
writeShellApplication {
  name = "nvidia-patch-extrator";
  runtimeInputs = [jq];

  text = ''
    bash "$1" -j
  '';
}
