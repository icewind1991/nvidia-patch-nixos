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
    in {
      packages = {
        inherit (pkgs) nvidia-patch-extractor;
        nvidia-patched = pkgs.nvidia-patch.patch-nvenc (pkgs.nvidia-patch.patch-fbc pkgs.linuxPackages.nvidiaPackages.stable);
      };
      devShell = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [jq patch];
      };
    })
    // {
      overlays.default = import ./overlay.nix;
    };
}
