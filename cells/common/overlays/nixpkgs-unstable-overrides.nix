{ inputs, cell, ... }:
final: prev:
let
  nixpkgs-unstable = import inputs.nixpkgs-unstable {
    inherit (inputs.nixpkgs) system;
    config.allowUnfree = true;
  };
in
{
  inherit
    (nixpkgs-unstable)
    gnupg
    sops

    nix-prefetch-scripts

    hyprlandPlugins

    ### cli/shell/terminal
    atuin

    tmux
    tmux-cssh
    tmux-mem-cpu-load
    tmux-sessionizer
    tmux-xpanes
    tmuxPlugins
    tmuxifier
    tmuxinator
    tmuxp

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
    openai-whisper-cpp
    ;

  nvfetcher = inputs.nvfetcher.packages.default;
  ssh-to-pgp = inputs.sops-ssh-to-pgp.packages.default;
  ssh-to-age = inputs.sops-ssh-to-age.packages.default;
}
