{ inputs, cell, ... }:

let
  inherit (inputs.n2c.packages.nix2container)
    pullImageFromManifest
    pullImage
    buildImage;

  pkgs = import inputs.nixpkgs-unstable {
    inherit (inputs.nixpkgs) system;
    config.allowUnfree = true;
    # overlays = [ ];
  };

  alpine = pullImage {
    imageName = "alpine";
    imageDigest = "sha256:115731bab0862031b44766733890091c17924f9b7781b79997f5f163be262178";
    arch = "amd64";
    sha256 = "sha256-o4GvFCq6pvzASvlI5BLnk+Y4UN6qKL2dowuT0cp8q7Q=";
  };

  alpine-test = buildImage {
    name = "from-image";
    fromImage = alpine;
    config = {
      entrypoint = [ "${pkgs.coreutils}/bin/ls" "-l" "/etc/alpine-release" ];
    };
  };

  # sudo docker run \
  #   --rm -ti \
  #   --user "$(id -u):$(id -g)" \
  #   --privileged \
  #   -v "/dev/bus/usb:/dev/bus/usb" \
  #   -v "$(realpath .):/app" \
  #   ghcr.io/ledgerhq/ledger-app-builder/ledger-app-dev-tools:latest
  #

  # NOTE: https://github.com/nlewo/nix2container/issues/72

  ledger-app-dev-tools_img = pullImage {
    imageName = "ghcr.io/ledgerhq/ledger-app-builder/ledger-app-dev-tools";
    imageDigest = "sha256:ae7e2261a9237268ad517348d096ba7709ec706ce69a936446c056a07d788873";
    sha256 = "sha256-Qxl5XE/7+ug8kt7dwvojyDr30kQVQORO8ZT2MVRlRZc=";
  };

  ledger-app-dev-tools_nix = buildImage {
    name = "ledger-app-dev-tools_nix";
    fromImage = ledger-app-dev-tools_img;
    config = {
      /*
          "Env": [
                "PATH=/opt/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "LANG=C.UTF-8",
                "NANOS_SDK=/opt/nanos-secure-sdk",
                "LEDGER_SECURE_SDK=/opt/ledger-secure-sdk",
                "NANOX_SDK=/opt/nanox-secure-sdk",
                "NANOSP_SDK=/opt/nanosplus-secure-sdk",
                "STAX_SDK=/opt/stax-secure-sdk",
                "BOLOS_SDK=/opt/nanos-secure-sdk",
                "RUST_STABLE=1.75.0",
                "RUST_NIGHTLY=nightly-2023-11-10",
                "RUSTUP_HOME=/opt/rustup",
                "CARGO_HOME=/opt/.cargo"
            ],

      */
      # volumes = { "/dev/bus/usb:/dev/bus/usb" = { }; };
      entrypoint = [ "${pkgs.coreutils}/bin/env" ];
    };
  };

in
{ inherit ledger-app-dev-tools_nix; }
