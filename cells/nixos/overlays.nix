{ inputs, cell, ... }:
let
  inherit (inputs.cells.common.packages)
    solarized-dark-gnome-shell
    solarized-material;
in
rec {
  firmwares = _: _: cell.firmwares;

  default_desktop = base
    ++ desktop
    ++ emacs
    ++ wayland
    ++ vscode;

  base = with inputs.cells.common.overlays; [
    inputs.nixd.overlays.default
    inputs.nix-filter.overlays.default
    nixpkgs-unstable-overrides
    nixpkgs-release-overrides
    nixpkgs-master-overrides
    # dart-fix
    base16-schemes
    # linux-firmware-fix
    sources
    python
  ];

  desktop = with inputs.cells.common.overlays;
    [
      numix-solarized-gtk-theme
      make-desktopitem
      masterpdfeditor # NOTE: required for 5.9.85
      firefox-addons
      # stumpwm
    ];

  wayland = [
    inputs.waybar.overlays.default
    inputs.hyprland.overlays.default
    inputs.hyprland-plugins.overlays.default
    # inputs.hyprland-hyprpicker.overlays.default
    inputs.hyprland-contrib.overlays.default
    inputs.hyprland-hyprlock.overlays.default
    inputs.hyprland-hypridle.overlays.default
    inputs.hyprland-hyprutils.overlays.default
    inputs.hyprland-hycov.overlays.default
    inputs.hyprland-xdg-desktop-portal.overlays.default

    (final: prev: {
      hyprlandPlugins = prev.hyprlandPlugins // {
        hy3 = inputs.hyprland-hy3.packages.${prev.system}.default;
        virtual-desktops = inputs.hyprland-virtual-desktops.packages.${prev.system}.default;
      };
    })
  ];
  /*
    mv "$tmp_dir/theme/gdm.css" "$tmp_dir/theme/original.css"
    echo '@import url("resource:///org/gnome/shell/theme/original.css");
    .login-dialog {
    background-color: '"$2"'; }' >"$tmp_dir/theme/gdm.css"
    CREATE_XML

    glib-compile-resources --sourcedir "$tmp_dir/theme" "$tmp_dir/theme/custom-gdm-background.gresource.xml"
    mv "$tmp_dir/theme/custom-gdm-background.gresource" "$dest"

    SET_GRESOURCE
  */
  gdm =
    { theme ? "Solarized-Dark-Green-3.36"
    , pkg ? solarized-dark-gnome-shell
    }: [
      (final: prev: {
        gnome = prev.gnome.overrideScope (gnomeFinal: gnomePrev: {
          gnome-shell = gnomePrev.gnome-shell.overrideAttrs (oldAttrs: {
            postFixup = (oldAttrs.postFixup or "") + ''
              cp ${pkg}/share/themes/${theme}/gdm/gnome-shell-theme.gresource \
                $out/share/gnome-shell/gnome-shell-theme.gresource
            '';
          });
        });
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
