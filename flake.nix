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
        config.allowUnfreePredicate = pkg: true;
      };
    in rec {
      packages = rec {
        inherit (pkgs) nvidia-patch-extractor nvidia-patch nvidia-patch-list;
        nvidia-patched = nvidia-patch.patch-nvenc (nvidia-patch.patch-fbc pkgs.linuxPackages.nvidiaPackages.stable);
      };
      devShell = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [jq patch];
      };
    })
    // {
      overlays.default = import ./overlay.nix;
    };
}
