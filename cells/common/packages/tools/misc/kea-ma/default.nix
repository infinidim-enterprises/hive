{ lib, sources, stdenv, dpkg }:

stdenv.mkDerivation rec {
  inherit (sources.kea-ma) src pname version;

  nativeBuildInputs = [ dpkg ];

  unpackPhase = "dpkg -x $src ./";

  installPhase = ''
    mkdir -p $out/bin
    mv usr/sbin/keama $out/bin/
    mv usr/share $out/

    for file in $out/bin/*; do
      chmod +w $file
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
               --set-rpath ${lib.makeLibraryPath [ stdenv.cc.cc ]} \
               $file
    done
  '';

  dontStrip = true;

}
