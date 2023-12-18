{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
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
            in {
              preFixup =
                preFixup
                + ''
                  version=${version}
                  driver_maj_version=''${version%%.*}
                  if [[ $driver_maj_version -ge "415" && $driver_maj_version -le "435" ]]; then
                      object='libnvcuvid.so'
                  else
                      object='libnvidia-encode.so'
                  fi

                  sed -i '${patch}' $out/lib/''${object}.''${version}
                '';
            });
        in {
          patch-nvenc = createPatch "" rev hash;
          patch-fbc = createPatch "fbc-" rev hash;
        };
      };
    };
}
