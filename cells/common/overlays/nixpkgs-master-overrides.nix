{ inputs, cell, ... }:
final: prev:
let
  inherit (inputs.nixpkgs-lib.lib // builtins)
    filterAttrs
    mapAttrs
    hasPrefix;
  nixpkgs-master = import inputs.nixpkgs-master {
    inherit (inputs.nixpkgs) system;
    config.allowUnfree = true;
  };
  hyprland-pkgs =
    {
      inherit
        (nixpkgs-master)
        # hyprlock
        # hypridle
        # hyprutils
        # hyprkeys
        # hyprcursor
        # hyprdim
        # hyprnome
        # hyprnotify
        # hyprpaper
        # hyprpicker
        # hyprpolkitagent
        # hyprprop
        # hyprshade
        # hyprshot
        # hyprsome
        # hyprsunset
        # hyprgraphics
        # hyprwayland-scanner

        aquamarine
        xdg-desktop-portal-hyprland
        weston
        wlroots
        sway
        xwayland;

    } // filterAttrs (n: _: hasPrefix "hypr" n) nixpkgs-master;
in
hyprland-pkgs //
{
  inherit
    (nixpkgs-master)
    # ISSUE: https://github.com/NixOS/nixpkgs/issues/368379#issuecomment-2563463801
    # also related: https://github.com/hyprwm/Hyprland/issues/6967
    # NOTE: latest hyprland wants at least mesa 24.3
    ###
    mesa
    ###

    gimp-with-plugins
    aider-chat
    activitywatch;
}
# //
# {
#   hyprlandCustom = mapAttrs
#     (n: v: prev.${n}.overrideAttrs (_: {
#       inherit (v) pname version src;
#     }))
#     hyprland-pkgs;
# }
