# nvidia-patch-nixos

nvidia-patch flake for NixOS

## Usage

- Add this flake to your flake inputs:
  ```
  nvidia-patch.url = "github:icewind1991/nvidia-patch-nixos";  
  nvidia-patch.inputs.nixpkgs.follows = "nixpkgs";
  ```

- Apply the overlay:
  ```
  nixpkgs.overlays = [inputs.nvidia-patch.overlays.default];
  ```

- Apply the patch to your nvidia package
  ```nix
  {
    pkgs,
    config,
    ...
  }: let
    # nvidia package to patch
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  in {
    hardware.nvidia.package = pkgs.nvidia-patch.patch-nvenc (pkgs.nvidia-patch.patch-fbc package);
  }
  
  ```

## Changelog

- 2024-04-31:
  - The overlay has been moved from `nvidia-patch.overlay` to `nvidia-patch.overlays.default`
  - You no longer need to provide the upstream `nvidia-patch` revision and hash.
  - The patcher no longer relies on [IFD](https://nixos.org/manual/nix/unstable/language/import-from-derivation) which should speedup builds.