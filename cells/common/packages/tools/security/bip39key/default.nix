{ sources
, rustPlatform
, lib
}:

rustPlatform.buildRustPackage {
  inherit (sources.misc.bip39key) src pname version;
  cargoLock = sources.misc.bip39key.cargoLock."Cargo.lock";

  meta.mainProgram = "bip39key";
  meta.license = lib.licenses.mit;
  meta.homepage = "https://github.com/jpdarago/bip39key";
  meta.description = "Generate an OpenPGP key from a BIP39 mnemonic";
}
