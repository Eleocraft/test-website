{
  bun2nix,
  runCommand,
  stdenv,
  lib,
  makeWrapper,
  bun,
  pname ? "test-website",
  version ? "0.0.1",
  ...
}:
let
  # Generated at build time from bun.lock so we don't keep a second file in
  # sync. bun2nix is a pure transformation here - bun.lock already contains
  # integrity hashes for every dependency, so no network access is needed.
  # This uses import-from-derivation: evaluation pauses until bun.nix is built.
  bunNix = runCommand "bun.nix" {
    nativeBuildInputs = [ bun2nix ];
  } ''
    bun2nix -l ${./bun.lock} -o $out
  '';
in
stdenv.mkDerivation {
  inherit pname;
  inherit version;

  src = ./.;

  nativeBuildInputs = [
    bun2nix.hook
    makeWrapper
  ];

  bunDeps = bun2nix.fetchBunDeps {
    inherit bunNix;
  };

  buildPhase = ''
    bun run build \
      --minify
  '';

  installPhase = ''
    mkdir -p $out/share/${pname} $out/bin

    cp -R ./build $out/share/${pname}/build

    makeWrapper ${lib.getExe bun} $out/bin/${pname} \
      --add-flags "$out/share/${pname}/build/index.js"
  '';

  meta.mainProgram = pname;
}
