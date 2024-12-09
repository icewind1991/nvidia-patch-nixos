{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/release-23.11";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
  }:
    utils.lib.eachDefaultSystem (system: let
      overlays = [
        (import ./overlay.nix)
      ];
      pkgs = (import nixpkgs) {
        inherit system overlays;
      };
    in rec {
      packages = rec {
        inherit (pkgs) nvidia-patch-extractor nvidia-patch nvidia-patch-list;
      };
      devShell = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [jq patch];
      };
    })
    // {
      overlays.default = import ./overlay.nix;
    };
}
