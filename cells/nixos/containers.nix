{ inputs, cell, ... }:
let
  inherit (inputs.std.lib.ops) mkOCI;
  inherit (inputs.n2c.packages.nix2container)
    pullImageFromManifest
    pullImage
    buildImage;


  alpine = pullImage {
    imageName = "alpine";
    imageDigest = "sha256:115731bab0862031b44766733890091c17924f9b7781b79997f5f163be262178";
    arch = "amd64";
    sha256 = "sha256-o4GvFCq6pvzASvlI5BLnk+Y4UN6qKL2dowuT0cp8q7Q=";
  };

  pkgs = import inputs.nixpkgs-unstable {
    inherit (inputs.nixpkgs) system;
    config.allowUnfree = true;
    # overlays = [ ];
  };

in
{
  # https://github.com/nlewo/nix2container/issues/72
  # std //nixos/containers/tcontainer:build  / load
  gpg-hd = mkOCI {
    name = "ghcr.io/infinidim-enterprises/hive";
    labels = {
      source = "https://github.com/infinidim-enterprises/hive:gpg-hd";
      description = "Deterministic key generator BIP39->GPG";
    };
    meta.tags = [ "gpg-hd" ];
    entrypoint = pkgs.bash;
    options = {
      fromImage = alpine;
    };
  };
}
