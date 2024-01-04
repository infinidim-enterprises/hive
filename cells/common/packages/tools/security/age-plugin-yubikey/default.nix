{ sources, rustPlatform, pkg-config, pcsclite }:
rustPlatform.buildRustPackage rec {
  inherit (sources.age-plugin-yubikey) pname version src;
  cargoLock = sources.age-plugin-yubikey.cargoLock."Cargo.lock";
  # cargoSha256 = "sha256-6J+xogL5t/FxStUz/hPrifhoGM95hyfTwJGntxRZ4U4=";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ pcsclite ];
}
# buildInputs = lib.optionals stdenv.isDarwin [ Security ];
# cargoSha256 = "1yivx9vzk2fvncvlkwq5v11hb9llr1zlcmy69y12q6xnd9rd8x1b";
