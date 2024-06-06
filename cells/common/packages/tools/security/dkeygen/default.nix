{ writeShellApplication
, writeText
, callPackage
, coreutils-full
, findutils
, qrencode
, openssh
, systemd
, ncurses
, expect
, gnused
, gnupg
, gawk
, lib
}:

let
  inherit (lib)
    tail
    splitString
    fileContents
    concatStringsSep;
  remove_shebang = txt: concatStringsSep "\n" (tail (splitString "\n" txt));
  pgp-key-generation = callPackage ../pgp-key-generation { };
in

writeShellApplication {
  name = "dkeygen";
  excludeShellChecks = [ "SC2206" "SC2034" ];
  bashOptions = [ "errexit" "pipefail" ];
  runtimeEnv.WORDLIST = writeText "bip39-wordlist" (fileContents ./bip39-english.txt);
  runtimeInputs = [
    pgp-key-generation
    coreutils-full
    findutils
    qrencode
    openssh
    systemd
    ncurses
    expect
    gnused
    gnupg
    gawk
  ];

  text = remove_shebang (fileContents ./dkeygen.sh);
}
