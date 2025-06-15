{ sources
, rustPlatform
, makeWrapper
, lib
}:

rustPlatform.buildRustPackage {
  inherit (sources.misc.bip39key-yubikey) src pname version;
  cargoLock = sources.misc.bip39key.cargoLock."Cargo.lock";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    mkdir -p "$out/resources"
    cp "resources/bip39.txt" "$out/resources/bip39.txt"

    wrapProgram "$out/bin/bip39key" --set WORDLIST_BIP39 $out/resources/bip39.txt
  '';

  meta.mainProgram = "bip39key";
  meta.license = lib.licenses.mit;
  meta.homepage = "https://github.com/jpdarago/bip39key";
  meta.description = "Generate an OpenPGP key from a BIP39 mnemonic";
}
