# nvidia-patch-nixos

nvidia-patch flake for NixOS

## Usage

- Add this flake to your flake inputs:
  ```
  nvidia-patch.url = "github:pizzaandcheese/nvidia-patch-nixos";  
  nvidia-patch.inputs.nixpkgs.follows = "nixpkgs";
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
    ...
  }: let
    rev = "af2616a252c990a8435bf86cf4788ce435474e24"; # revision from https://github.com/keylase/nvidia-patch to use
    hash = "sha256-yocxfo7YvBCpHVV/ZhNQssyd3L9jvMFP7tz0cQucLr4="; # sha256sum for https://github.com/keylase/nvidia-patch at the specified revision
    
    # create patch functions for the specified revision
    nvidia-patch = pkgs.nvidia-patch rev hash;
  
    # nvidia package to patch
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  in {
    hardware.nvidia.package = nvidia-patch.patch-nvenc (nvidia-patch.patch-fbc package);
  }
  
  ```
