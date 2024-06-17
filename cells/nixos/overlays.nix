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

  wayland = [
    inputs.waybar.overlays.default
    inputs.hyprland.overlays.default
    inputs.hyprland.overlays.xwayland
    inputs.hyprland-plugins.overlays.default
    (final: prev: {
      hyprlandPlugins = prev.hyprlandPlugins // { hy3 = inputs.hyprland-hy3.packages.${prev.system}.default; };
    })
  ];

  emacs = [
    inputs.cells.emacs.overlays.sources
    # inputs.cells.emacs.overlays.tools
  ];

  vscode = with inputs.cells.common.overlays; [
    vscode-extensions
  ];
}
