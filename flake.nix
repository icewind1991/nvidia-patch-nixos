{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/release-22.05";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
  }:
    utils.lib.eachDefaultSystem (system: let
      pkgs = (import nixpkgs) {
        inherit system;
      };
      rev = "0fa9170";
      hash = "sha256-+BkDUfVqqYMAG62OarNPJiNfghvHpOhhMlS5H+SV1dQ=";
    in rec {
      # `nix develop`
      devShell = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [jq patch];
      };

      extract = pkgs.callPackage ./extract.nix {};
      createPatch = prefix: driverPackage: rev: hash: driverPackage.overrideAttrs ({
        version,
        preFixup ? "",
        ...
      }: let
        inherit (nixpkgs.lib) importJSON traceVal;
        jsons = extract rev hash;
        patchList = importJSON "${jsons}/${prefix}patch-list.json";
        objectList = importJSON "${jsons}/${prefix}object-list.json";
        object = (traceVal objectList.${version});
        patch = (traceVal patchList.${version});
      in {
        preFixup =
          preFixup
          + ''
            sed -i '${patch}' $out/lib/${object}.${version}
          '';
      });
      patchNvenc = createPatch "";
      patchFbc = createPatch "fbc-";
    });
}
