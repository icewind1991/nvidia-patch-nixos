{
  lib,
  writeShellApplication,
  patch,
  jq,
}:
writeShellApplication {
  name = "nvidia-patch-extrator";
  runtimeInputs = [patch jq];

  text = ''
    mkdir -p /tmp/nvidia-patch
    cp "$1" /tmp/nvidia-patch/patch.sh
    cd /tmp/nvidia-patch
    patch -p1 < ${./extract-patch-list.diff} 1>&2
    bash patch.sh
  '';
}
