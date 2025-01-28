{ inputs, cell, ... }:

rec {
  # TODO: MAYBE remove and rework default, base
  base = default;
  default =
    # NOTE: This always gets applied from lib.mkHome
    [{ disabledModules = inputs.cells.common.lib.disableModulesFrom ./homeModules; }] ++
    cli;

  cli = with cell.homeProfiles; [
    xdg
    shell.zsh
    shell.atuin
    shell.screen
    shell.cli-tools
    look-and-feel.solarized-dark
    look-and-feel.starship-prompt

    inputs.cells.home.homeModules.programs.waveterm
  ];

  desktop = with cell.homeProfiles; [
    # emacs
    remmina
    terminals.tilix
    # terminals.kitty
    # conky

    look-and-feel.nerdfonts-ubuntu
    look-and-feel.pointer-cursor
  ];

  wayland = with cell.homeProfiles.wayland; [
    wofi
    waybar
    wlogout
    dunst
    hyprland
    kanshi
  ] ++ desktop;

  office = with cell.homeProfiles.office; [
    pdf
    viewers
    printing
    graphics
    onlyoffice
    libreoffice
    archive_manager
  ];

  developer.default = with cell.homeProfiles.developer; [
    git
    direnv
    nix
  ];
}
