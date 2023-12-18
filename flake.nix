{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/release-23.05";
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
      rev = "af2616a252c990a8435bf86cf4788ce435474e24";
      hash = "sha256-yocxfo7YvBCpHVV/ZhNQssyd3L9jvMFP7tz0cQucLr4=";
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
              patch = patchList.${version};
              object = "libnvidia-encode.so";
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
