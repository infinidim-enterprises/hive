{ inputs, cell, ... }:
let
  inherit (inputs.cells.common.packages)
    solarized-dark-gnome-shell
    solarized-material;
in
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
    inputs.hyprland-plugins.overlays.default

    (final: prev: {
      hyprlandPlugins = prev.hyprlandPlugins // {
        hy3 = inputs.hyprland-hy3.packages.${prev.system}.default;
        hych = inputs.hyprland-hych.packages.${prev.system}.hych;
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
    { theme ? "Material-Solarized" # "Solarized-Dark-Green-3.36"
    , pkg ? solarized-material
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
