# nvidia-patch-nixos

nvidia-patch flake for NixOS

## Usage

- Add this flake to your flake inputs:
  ```
  nvidia-patch.url = "github:icewind1991/nvidia-patch-nixos";
  ```

- Apply the overlay:
  ```
  nixpkgs.overlays = [inputs.nvidia-patch.overlay];
  ```

- Apply the patch to your nvidia package
  ```nix
  {
    pkgs,
    config,
    inputs,
    system,
    ...
  }: let
    rev = "0fa9170"; # revision from https://github.com/keylase/nvidia-patch to use
    hash = "sha256-+BkDUfVqqYMAG62OarNPJiNfghvHpOhhMlS5H+SV1dQ="; # sha256sum for https://github.com/keylase/nvidia-patch at the specified revision
    
    # create patch functions for the specified revision
    nvidia-patch = pkgs.nvidia-patch rev hash;
  
    # nvidia package to patch
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  in {
    hardware.nvidia.package = nvidia-patch.patch-nvenc (nvidia-patch.patch-fbc package);
  }
  
  ```