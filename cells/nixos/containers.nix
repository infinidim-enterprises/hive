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

  uname = "gpg-hd";
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
    inputs.cells.common.packages.gpg-hd
    gawk
    bash
    gnupg
    gnugrep
    coreutils
    monkeysphere
  ];
in
{
  # std //nixos/containers/gpg-hd:{build,load,publish}
  # NOTE: https://github.com/nlewo/nix2container/issues/72
  gpg-hd = mkOCI {
    inherit uid gid runtimeInputs;
    name = "ghcr.io/infinidim-enterprises/hive";
    labels = {
      source = "https://github.com/infinidim-enterprises/hive:gpg-hd";
      description = "Deterministic key generator BIP39->GPG";
    };
    meta.tags = [ "gpg-hd" ];
    # entrypoint = inputs.cells.common.packages.gpg-hd;
    entrypoint = pkgs.bash;

    config.Env = [
      "USER=${uname}"
      "HOME=/home/${uname}"
      "NIX_PAGER=cat"
      "PATH=${pkgs.lib.makeBinPath runtimeInputs}"
    ];
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
}
