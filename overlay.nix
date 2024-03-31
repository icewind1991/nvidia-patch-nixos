final: prev: {
  nvidia-patch-extractor = final.callPackage ./extractor.nix {};
  nvidia-patch = final.callPackage ./patch.nix {};
}
