{ inputs, cell, ... }:
let
  lib = inputs.nixpkgs-lib.lib // builtins;
in
rec {

  base = with cell.nixosProfiles; [
    sudo
    earlyoom
    core.locale
    core.console-solarized
    core.boot-config
    core.packages
    core.shell-defaults
  ]
  ++ [ ({ config, ... }: { system.stateVersion = config.bee.pkgs.lib.trivial.release; }) ]
  ++ [ (cell.lib.mkHome "admin" "zsh") ]
  ++ [ inputs.cells.home.userProfiles.root ]
  ++ [ cell.nixosModules.deploy ]
  ++ [ inputs.cells.common.nixosProfiles.nix-config ];

  # TODO: desktop profiles with different window managers
  desktop = base
    ++ (with cell.nixosProfiles.desktop; [
    common
    dconf
    fonts
    multimedia # bluetooth only atm
    xdg
    # TODO: desktop.opensnitch
  ])
    ++ [ ({ pkgs, ... }: { environment.systemPackages = with pkgs; [ networkmanagerapplet ]; }) ];
  # ++ [ inputs.cells.secrets.nixosProfiles.common ];

  cli = base ++ [ inputs.cells.secrets.nixosProfiles.common ];

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
