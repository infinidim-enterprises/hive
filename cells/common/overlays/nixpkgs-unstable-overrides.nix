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
    sops

    hyprlandPlugins

    atuin
    waveterm
    nyxt

    nerd-fonts

    direnv
    editorconfig-checker

    pgcli
    beekeeper-studio

    tilix
    flameshot

    android-tools
    libadwaita
    vscode

    alejandra
    nil
    nixpkgs-fmt
    statix
    # nixUnstable
    cachix
    nix-index

    ctop
    terraform
    terraform-ls

    remmina
    freerdp

    openvswitch
    libvirt
    qemu_kvm
    virt-manager
    spice-gtk

    kubelogin-oidc
    minikube
    kubernetes-helm
    wrapHelm
    kubectl
    kubernetes-helmPlugins

    amazon-ecr-credential-helper

    dive# dive - A tool for exploring each layer in a docker image
    act# act - Run your GitHub Actions locally

    tailscale
    ffmpeg_5-full
    ;

  nvfetcher = inputs.nvfetcher.packages.default;
  ssh-to-pgp = inputs.sops-ssh-to-pgp.packages.default;
  ssh-to-age = inputs.sops-ssh-to-age.packages.default;
}
