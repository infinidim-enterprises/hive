{ pkg-config, openssl, rustPlatform, sources }:

rustPlatform.buildRustPackage {
  inherit (sources.zeronsd) src pname version;
  cargoLock = sources.zeronsd.cargoLock."Cargo.lock";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
}
