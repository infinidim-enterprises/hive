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
    (final: prev: { inherit (inputs.nixd.packages) nixd; })
    # inputs.nixd.overlays.default
    # inputs.nix-filter.overlays.default
    nixpkgs-master-overrides
    # NOTE: switched to release-25.05 nixpkgs-unstable-overrides
    # NOTE: switched to release-25.05 nixpkgs-release-overrides
    # dart-fix
    base16-schemes
    # linux-firmware-fix
    atuin
    wofi-pass
    sources
    python
    (final: prev: {
      libs3 = prev.libs3.overrideAttrs (old: {
        postPatch = old.postPatch or "" + ''
          sed -i 's/-Werror[=a-z\-]*//g' GNUmakefile
        '';
      });
    })
  ];

  desktop = with inputs.cells.common.overlays;
    [
      numix-solarized-gtk-theme
      make-desktopitem
      masterpdfeditor # NOTE: required for 5.9.85
      # TODO: nyxt with sly-quicklisp
      (final: prev:
        { sources = prev.sources // (final.callPackage ./sources/generated.nix { }); }
      )
    ];

  wayland = [ inputs.cells.common.overlays.hyprland ];
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

  llm = [
    inputs.cells.llm.overlays.sources
  ];

  emacs = [
    inputs.cells.emacs.overlays.sources
    # inputs.cells.emacs.overlays.tools
  ];

  vscode = with inputs.cells.common.overlays; [
    vscode-extensions
  ];
}
