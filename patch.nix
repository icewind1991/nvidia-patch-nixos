{ nvidia-patch-list }:
let
  createPatch =
    patchList: object: driverPackage:
    driverPackage.overrideAttrs (
      {
        version,
        preFixup ? "",
        ...
      }:
      let
        patch = patchList.${version};
      in
      {
        preFixup = preFixup + ''
          sed -i '${patch}' $out/lib/${object}.${version}
        '';
      }
    );

  patch-nvenc = createPatch nvidia-patch-list.nvenc "libnvidia-encode.so";
  patch-fbc = createPatch nvidia-patch-list.fbc "libnvidia-fbc.so";

  auto-patch =
    nvidiaPackage:
    let
      maybeFbc =
        if builtins.hasAttr nvidiaPackage.version nvidia-patch-list.fbc then
          patch-fbc nvidiaPackage
        else
          nvidiaPackage;

      maybeNvenc =
        if builtins.hasAttr maybeFbc.version nvidia-patch-list.nvenc then
          patch-nvenc maybeFbc
        else
          maybeFbc;

      nvidiaPackageFinal = maybeNvenc;
    in
    nvidiaPackageFinal;
in
{
  inherit patch-nvenc patch-fbc auto-patch;
}
