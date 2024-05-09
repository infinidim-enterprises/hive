{ inputs, cell, ... }:
{
  firmwares = _: _: cell.firmwares;

  base = with inputs.cells.common.overlays; [
    nixpkgs-unstable-overrides
    nixpkgs-master-overrides
    dart-fix
    sources
    python
  ];

  desktop = with inputs.cells.common.overlays;
    [
      numix-solarized-gtk-theme
      make-desktopitem
      # NOTE: obsolete masterpdfeditor
      firefox-addons
      stumpwm-new
    ];

  emacs = [
    inputs.cells.emacs.overlays.sources
    # inputs.cells.emacs.overlays.tools
  ];

  developer = with inputs.cells.common.overlays; [
    vscode-extensions
  ];
}
