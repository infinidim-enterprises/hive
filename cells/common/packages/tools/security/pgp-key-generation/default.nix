{ sources
, cryptopp
, libsodium
  # , boost
, boost179
, cmake
, stdenv
, pkg-config
}:

let
  common_buildInputs = [
    cryptopp
    libsodium
    # boost
    boost179
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  pgp-packet-library = stdenv.mkDerivation {
    inherit (sources.pgp-packet-library) pname version src;
    inherit nativeBuildInputs;

    buildInputs = common_buildInputs;
  };
in

stdenv.mkDerivation {
  inherit (sources.pgp-key-generation) pname version src;
  inherit nativeBuildInputs;

  buildInputs = common_buildInputs ++ [ pgp-packet-library ];

  installPhase = ''
    mkdir -p $out/bin
    cp ./extend_key_expiry/extend_key_expiry $out/bin/extend_key_expiry
    cp ./generate_derived_key/generate_derived_key $out/bin/generate_derived_key
  '';

  meta = {
    description = "Utility to generate deterministic PGP keys";
    homepage = "https://github.com/summitto/pgp-key-generation";
    mainProgram = "generate_derived_key";
  };
}
