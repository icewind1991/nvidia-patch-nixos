{
  stdenv,
  lib,
  jq,
  fetchFromGitHub,
  patch,
}: rev: sha256:
stdenv.mkDerivation rec {
  pname = "nvidia-patch";
  version = rev;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "keylase";
    repo = pname;
  };

  nativeBuildInputs = [
    jq
    patch
  ];

  dontConfigure = true;

  buildPhase = ''
    cp ${src}/patch.sh patch.sh
    patch -p1 < ${./extract-patch-list.diff}
    bash patch.sh > patch-list.json

    cp ${src}/patch-fbc.sh patch.sh
    patch -p1 < ${./extract-patch-list.diff}
    bash patch.sh > fbc-patch-list.json
  '';

  installPhase = ''
    mkdir -p $out
    cp *.json $out
  '';
}
