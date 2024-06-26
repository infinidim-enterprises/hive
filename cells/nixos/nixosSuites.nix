{ inputs, cell, ... }:
let
  lib = inputs.nixpkgs-lib.lib // builtins;
in
rec {

  base = with cell.nixosProfiles; [
    (cell.lib.mkHome "admin" "zsh")
    inputs.cells.home.userProfiles.root

    sudo
    earlyoom
    core.locale
    # TODO: [ fork/rewrite stylix ] core.stylix
    core.console-solarized
    core.boot-config
    core.packages
    core.shell-defaults
    hardware.cryptography

    cell.nixosModules.deploy

    inputs.cells.secrets.nixosProfiles.common
    inputs.cells.common.nixosProfiles.nix-config
    ({ config, ... }: { system.stateVersion = config.bee.pkgs.lib.trivial.release; })
  ];

  # TODO: desktop profiles with different window managers
  desktop = base
    ++ (with cell.nixosProfiles.desktop; [
    common
    chromium-browser
    dconf
    fonts
    multimedia # bluetooth only atm
    xdg
    wayland
    # displayManager.gdm # NOTE: works with hyprland
    displayManager.sddm
    # displayManager.lightdm
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
