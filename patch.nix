{lib}: let
  inherit (lib) importJSON;
  createPatch = json: object: driverPackage:
    driverPackage.overrideAttrs ({
      version,
      preFixup ? "",
      ...
    }: let
      patchList = importJSON json;
      patch = patchList.${version};
    in {
      preFixup =
        preFixup
        + ''
          sed -i '${patch}' $out/lib/${object}.${version}
        '';
    });
in {
  patch-nvenc = createPatch ./patch.json "libnvidia-encode.so";
  patch-fbc = createPatch ./patch-fbc.json "libnvidia-fbc.so";
}
