{ inputs, cell, ... }:
final: prev:
let
  inherit (inputs.nixpkgs-lib.lib // builtins)
    hasAttrByPath
    filterAttrs
    mapAttrs
    hasAttr;

  flakeGet = path: _:
    cell.lib.callFlake final.sources.hyprwm.${path}.src;

  hyprwm_flakes_all = mapAttrs flakeGet
    (filterAttrs (_: v: hasAttr "flake" v && v.flake == "true")
      final.sources.hyprwm);

  hyprwm_flakes_with_input_hyprland = mapAttrs
    (_: v: cell.lib.callFlakeWithOverrides {
      src = v.outPath;
      overrides = { hyprland = hyprwm_flakes.hy3.inputs.hyprland.outPath; };
    })
    (filterAttrs
      (n: v: n != "hy3" && hasAttrByPath [ "inputs" "hyprland" ] v)
      hyprwm_flakes_all);

  hyprwm_flakes = hyprwm_flakes_all // hyprwm_flakes_with_input_hyprland;

  release = import inputs.nixpkgs {
    inherit (inputs.nixpkgs) system;
    config.allowUnfree = true;
    overlays = [
      hyprwm_flakes.hyprlock.overlays.default
      hyprwm_flakes.hypridle.overlays.default
      hyprwm_flakes.hyprland-plugins.overlays.default
      hyprwm_flakes.hyprpicker.overlays.default
      hyprwm_flakes.contrib.overlays.default
      hyprwm_flakes.hyprsysteminfo.overlays.default
      hyprwm_flakes.grim-hyprland.overlays.default
      hyprwm_flakes.hy3.inputs.hyprland.overlays.default

      hyprwm_flakes.waybar.overlays.default
      (_: prv: {
        waybar = prv.waybar.overrideAttrs (_: {
          __intentionallyOverridingVersion = true;
          inherit (final.sources.hyprwm.waybar) version;
        });
      })
    ];
  };

in

{
  # sources = prev.sources // { inherit hyprwm_flakes; };

  inherit (release)
    waybar
    hyprsysteminfo

    hyprlock
    hypridle
    hyprpicker

    grimblast
    hdrop
    hyprprop
    scratchpad
    shellevents
    try_swap_workspace

    grim

    aquamarine
    hyprcursor
    hyprgraphics
    hyprland-protocols
    hyprland-qtutils
    hyprlang
    hyprutils
    hyprwayland-scanner
    udis86
    wayland-protocols
    xdg-desktop-portal-hyprland
    sdbus-cpp_2
    hyprland;

  inherit (hyprwm_flakes.pyprland.packages.${inputs.nixpkgs.system}) pyprland;

  hyprlandPlugins =
    prev.hyprlandPlugins //
    release.hyprlandPlugins //
    {
      Hyprspace = hyprwm_flakes.Hyprspace.packages.${inputs.nixpkgs.system}.default;
      hy3 = hyprwm_flakes.hy3.packages.${inputs.nixpkgs.system}.default;
    };
}

/*
  execinfo
  epoll-shim
  libinotify
  tracy
*/
