{ inputs, cell, ... }:
let
  inherit (inputs.std.lib.ops) mkOCI;
  inherit (inputs.n2c.packages.nix2container)
    pullImageFromManifest
    pullImage
    buildImage
    buildLayer;

  pkgs = import inputs.nixpkgs-pycrypto-pinned {
    inherit (inputs.nixpkgs) system;
    config.allowUnfree = true;
  };

  # alpine = pullImage {
  #   imageName = "alpine";
  #   imageDigest = "sha256:115731bab0862031b44766733890091c17924f9b7781b79997f5f163be262178";
  #   arch = "amd64";
  #   sha256 = "sha256-o4GvFCq6pvzASvlI5BLnk+Y4UN6qKL2dowuT0cp8q7Q=";
  # };


  # gpg-hd-image = buildImage {
  #   name = "gpg-hd";
  #   layers = [
  #     (buildLayer { deps = with pkgs; [ coreutils bash inputs.cells.common.packages.gpg-hd ]; })
  #   ];
  # };

  uname = "dkeygen";
  gname = "users";
  uid = "1000";
  gid = "100";

  mkUser = pkgs.runCommand "mkUser" { } ''
    mkdir -p $out/etc/pam.d

    echo "${uname}:x:${uid}:${gid}::/home/${uname}" > $out/etc/passwd
    echo "${uname}:!x:::::::" > $out/etc/shadow

    echo "${gname}:x:${gid}:" > $out/etc/group
    echo "${gname}:x::" > $out/etc/gshadow

    cat > $out/etc/pam.d/other <<EOF
    account sufficient pam_unix.so
    auth sufficient pam_rootok.so
    password requisite pam_unix.so nullok sha512
    session required pam_unix.so
    EOF

    touch $out/etc/login.defs
    mkdir -p $out/home/${uname}
  '';
  runtimeInputs = with pkgs; [
    gawk
    bash
    gnupg
    coreutils-full
    gnugrep
    inputs.cells.common.packages.pgp-key-generation
    # monkeysphere
  ];

  keygen_script = pkgs.writeShellApplication {
    name = "dkeygen";
    excludeShellChecks = [ "SC2206" "SC2034" ];
    bashOptions = [ "errexit" "pipefail" ];
    runtimeEnv.WORDLIST = pkgs.writeText "bip39-wordlist" (pkgs.lib.fileContents ./nixosProfiles/hardware/crypto/bip39-english.txt);
    runtimeInputs = with pkgs; [
      inputs.cells.common.packages.pgp-key-generation
      coreutils-full
      findutils
      qrencode
      openssh
      systemd
      expect
      gnused
      gnupg
      gawk
    ];

    text =
      with pkgs.lib;
      let
        remove_shebang = txt: concatStringsSep "\n" (tail (splitString "\n" txt));
      in
      remove_shebang (fileContents ./nixosProfiles/hardware/crypto/dkeygen.sh);
  };

in
{
  # std //nixos/containers/dkeygen:{build,load,publish}
  # NOTE: https://github.com/nlewo/nix2container/issues/72
  dkeygen = mkOCI {
    inherit uid gid runtimeInputs;
    name = "ghcr.io/infinidim-enterprises/hive";
    labels = {
      source = "https://github.com/infinidim-enterprises/hive:dkeygen";
      description = "Deterministic key generator BIP39->GPG";
    };
    meta.tags = [ "dkeygen" ];
    # entrypoint = inputs.cells.common.packages.gpg-hd;
    entrypoint = pkgs.bash;

    config.Env = [
      "USER=${uname}"
      "HOME=/home/${uname}"
      "NIX_PAGER=cat"
      "PATH=${pkgs.lib.makeBinPath (runtimeInputs ++ [ keygen_script ])}"
    ];

    config.volumes."/tmp" = { };

    setup = [ mkUser ];

    perms = [{
      inherit uname gname;
      path = mkUser;
      regex = "/home/${uname}";
      mode = "0744";
      uid = pkgs.lib.toInt uid;
      gid = pkgs.lib.toInt gid;
    }];

    # options = {
    #   fromImage = gpg-hd-image;
    # };
  };
  inherit keygen_script;
}
