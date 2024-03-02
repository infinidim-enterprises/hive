{ inputs, cell, ... }:

rec {
  # TODO: MAYBE remove and rework default, base
  base = default;
  default =
    [{ disabledModules = inputs.cells.common.lib.disableModulesFrom ./homeModules; }] ++
    cli;

  cli = with cell.homeProfiles; [
    xdg
    shell.zsh
    shell.atuin
    shell.screen
    shell.cli-tools
    look-and-feel.starship-prompt
  ];

  desktop = with cell.homeProfiles; [
    # emacs
    remmina
    terminals.tilix
    terminals.kitty
    conky
    qt
  ];

  office = with cell.homeProfiles.office; [
    pdf
    viewers
    printing
    graphics
    libreoffice
    onlyoffice
  ];

  developer.default = [ cell.homeProfiles.developer.git ];
}
