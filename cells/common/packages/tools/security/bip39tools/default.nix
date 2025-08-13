{ lib
, stdenv
, cmake
, git
, sources
}:

let
  tacent = stdenv.mkDerivation {
    inherit (sources.misc.tacent)
      src
      pname
      version;
    nativeBuildInputs = [ cmake ];
    cmakeFlags = [ "-DBUILD_TESTING=OFF" ];
  };
in

stdenv.mkDerivation {
  inherit (sources.misc.bip39tools)
    src
    pname
    version;

  buildInputs = [ git tacent ];
  nativeBuildInputs = [ cmake ];
  cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  installPhase = ''
    mkdir -p $out/bin
    cp bin/* $out/bin/
  '';

  meta = with lib; {
    description = "C++ CLI utilities for generating and validating BIP39 mnemonics";
    homepage = "https://github.com/bluescan/bip39tools";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
