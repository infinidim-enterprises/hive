{ inputs, cell, ... }:
final: prev:
let
  latest = import inputs.latest {
    inherit (inputs.nixpkgs) system;
    config.allowUnfree = true;
  };
in
{
  inherit
    (latest)
    gnupg
    editorconfig-checker

    android-tools
    vscode
    alejandra
    rnix-lsp
    nil
    terraform
    terraform-ls
    kubelogin-oidc
    minikube
    kubernetes-helm
    nixpkgs-fmt
    statix
    nixUnstable
    cachix
    nix-index
    _1password
    wrapHelm
    kubectl
    kubernetes-helmPlugins
    direnv
    amazon-ecr-credential-helper


    dive# dive - A tool for exploring each layer in a docker image
    act# act - Run your GitHub Actions locally

    tailscale
    ffmpeg_5-full
    sops
    ;

  nvfetcher = inputs.nvfetcher.packages.default;
  ssh-to-pgp = inputs.sops-ssh-to-pgp.packages.default;
  ssh-to-age = inputs.sops-ssh-to-age.packages.default;
}
