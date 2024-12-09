{nvidia-patch-list}: let
  createPatch = patchList: object: driverPackage:
    driverPackage.overrideAttrs ({
      version,
      preFixup ? "",
      ...
    }: let
      patch = patchList.${version};
    in {
      preFixup =
        preFixup
        + ''
          sed -i '${patch}' $out/lib/${object}.${version}
        '';
    });
in {
  patch-nvenc = createPatch nvidia-patch-list.nvenc "libnvidia-encode.so";
  patch-fbc = createPatch nvidia-patch-list.fbc "libnvidia-fbc.so";
}
