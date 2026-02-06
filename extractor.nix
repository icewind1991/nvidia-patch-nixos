{
  writeShellApplication,
  jq,
}:
writeShellApplication {
  name = "nvidia-patch-extrator";
  runtimeInputs = [jq];

  text = ''
    tmpscript=$(mktemp)
    trap 'rm -f "$tmpscript"' EXIT
    cp "$1" "$tmpscript"
    # bypass "root check"
    sed -i 's/ne 0/eq 0/' "$tmpscript"
    bash "$tmpscript" -j
  '';
}
