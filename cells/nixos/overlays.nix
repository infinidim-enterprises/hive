{ inputs, cell, ... }:
{
  firmwares = _: _: cell.firmwares;

  base = with inputs.cells.common.overlays; [
    inputs.nix-filter.overlays.default
    nixpkgs-unstable-overrides
    nixpkgs-release-overrides
    nixpkgs-master-overrides
    dart-fix
    base16-schemes
    # linux-firmware-fix
    sources
    python
  ];

  desktop = with inputs.cells.common.overlays;
    [
      numix-solarized-gtk-theme
      make-desktopitem
      # NOTE: obsolete masterpdfeditor
      firefox-addons
      stumpwm
    ];

  emacs = [
    inputs.cells.emacs.overlays.sources
    # inputs.cells.emacs.overlays.tools
  ];

  vscode = with inputs.cells.common.overlays; [
    vscode-extensions
  ];
}
