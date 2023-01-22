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
    })
    // {
      overlay = final: prev: {
        nvidia-patch = rev: hash: let
          inherit (nixpkgs.lib) importJSON;
          extract = final.callPackage ./extract.nix {};
          jsons = extract rev hash;
          createPatch = prefix: rev: hash: driverPackage:
            driverPackage.overrideAttrs ({
              version,
              preFixup ? "",
              ...
            }: let
              patchList = importJSON "${jsons}/${prefix}patch-list.json";
              objectList = importJSON "${jsons}/${prefix}object-list.json";
              patch = patchList.${version};
              object = objectList.${version};
            in {
              preFixup =
                preFixup
                + ''
                  sed -i '${patch}' $out/lib/${object}.${version}
                '';
            });
        in {
          patch-nvenc = createPatch "" rev hash;
          patch-fbc = createPatch "fbc-" rev hash;
        };
      };
    };
}
