{ inputs, cell, ... }:
final: prev:
let
  inherit (inputs.nixpkgs-lib.lib // builtins)
    toString
    mapAttrs
    removeAttrs;

  flakeGet = path: _:
    let
      drv = final.sources.hyprwm.${path}.src;
      Path = builtins.path {
        path = drv.outPath;
        name = "realized-${drv.name}";
      };
    in
    inputs.call-flake (toString Path);

  hyprwm_flakes = mapAttrs flakeGet
    (removeAttrs final.sources.hyprwm [ "override" "overrideDerivation" ]);

  master = import inputs.nixpkgs-master {
    inherit (inputs.nixpkgs) system;
    config.allowUnfree = true;
  };

  release = import inputs.nixpkgs {
    inherit (inputs.nixpkgs) system;
    config.allowUnfree = true;
    overlays = [
      (fin: prev: {
        inherit (master)
          # ISSUE: https://github.com/NixOS/nixpkgs/issues/368379#issuecomment-2563463801
          # also related: https://github.com/hyprwm/Hyprland/issues/6967
          # NOTE: latest hyprland wants at least mesa 24.3
          ###
          mesa
          libgbm
          weston
          wlroots
          sway
          xwayland;
      })
      hyprwm_flakes.hyprlock.overlays.default
      hyprwm_flakes.hypridle.overlays.default
      hyprwm_flakes.hyprland-plugins.overlays.default
      hyprwm_flakes.hyprpicker.overlays.default
      hyprwm_flakes.contrib.overlays.default
      hyprwm_flakes.hy3.inputs.hyprland.overlays.default
    ];
  };

in

{
  # sources = prev.sources // { inherit hyprwm_flakes; };

  inherit (release)
    mesa
    libgbm
    weston
    wlroots
    sway
    xwayland

    hyprlock
    hypridle
    hyprpicker

    grimblast
    hdrop
    hyprprop
    scratchpad
    shellevents
    try_swap_workspace

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

  hyprlandPlugins =
    prev.hyprlandPlugins //
    release.hyprlandPlugins //
    { hy3 = hyprwm_flakes.hy3.packages.${inputs.nixpkgs.system}.default; };
}

/*
  execinfo
  epoll-shim
  libinotify
  tracy
*/
