final: prev: {
  nvidia-patch-extractor = final.callPackage ./extractor.nix {};
  nvidia-patch = final.callPackage ./patch.nix {};
  nvidia-patch-list = {
    nvenc =  final.callPackage ./patchlist.nix { json = ./patch.json; };
    fbc =  final.callPackage ./patchlist.nix { json = ./patch-fbc.json; };
  };
}
