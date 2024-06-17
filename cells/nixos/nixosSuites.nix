{ inputs, cell, ... }:
let
  lib = inputs.nixpkgs-lib.lib // builtins;
in
rec {

  base = with cell.nixosProfiles; [
    sudo
    earlyoom
    core.locale
    # TODO: [ fork/rewrite stylix ] core.stylix
    core.console-solarized
    core.boot-config
    core.packages
    core.shell-defaults

    cell.nixosModules.deploy
    inputs.cells.secrets.nixosProfiles.common
    inputs.cells.common.nixosProfiles.nix-config
    ({ config, ... }: { system.stateVersion = config.bee.pkgs.lib.trivial.release; })
  ]
  ++ [ inputs.cells.home.userProfiles.root (cell.lib.mkHome "admin" "zsh") ];

  # TODO: desktop profiles with different window managers
  desktop = base
    ++ (with cell.nixosProfiles.desktop; [
    common
    dconf
    fonts
    multimedia # bluetooth only atm
    xdg
    wayland
    displayManager.gdm # NOTE: works with hyprland
    # TODO: desktop.opensnitch
  ])
    ++ [ ({ pkgs, ... }: { environment.systemPackages = with pkgs; [ networkmanagerapplet ]; }) ];

  cli = base;

  networking = [
    cell.nixosProfiles.networking.networkd
    cell.nixosProfiles.networking.firewall
    cell.nixosProfiles.networking.openssh
    cell.nixosProfiles.networking.adguardhome
  ];

  virtualization = [
    cell.nixosProfiles.virtualization.libvirtd
    cell.nixosProfiles.virtualization.docker
  ];

  bootstrap = [ ];
}
