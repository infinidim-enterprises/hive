{ inputs, cell, ... }:
final: prev:
let
  # inherit (inputs.nixpkgs-lib.lib // builtins)
  #   mapAttrs
  #   filterAttrs
  #   isDerivation
  #   hasPrefix;

  nixpkgs-master = import inputs.nixpkgs-master {
    inherit (inputs.nixpkgs) system;
    config.allowUnfree = true;
  };

  # buildWithNewerSrc = attrs: mapAttrs
  #   (n: v: prev.${n}.overrideAttrs (_: {
  #     inherit (v) pname version src;
  #   }))
  #   (filterAttrs (_: v: isDerivation v) attrs);

  # hyprland-pkgs =
  #   {
  #     inherit
  #       (nixpkgs-master)
  #       aquamarine
  #       xdg-desktop-portal-hyprland
  #       weston
  #       wlroots
  #       sway
  #       xwayland;
  #   } // filterAttrs (n: _: hasPrefix "hypr" n) nixpkgs-master;
in

# hyprland-pkgs //

{
  inherit
    (nixpkgs-master)
    formats

    aider-chat;
} //

{
  kdeconnect-kde-recent = nixpkgs-master.kdePackages.kdeconnect-kde;
  # copyq = prev.copyq.overrideAttrs (oldAttrs: {
  #   inherit (nixpkgs-master.copyq) src version;
  #   nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ prev.pkg-config ];
  #   patches = [ ];
  # });
}

# //
# {
#   hyprlandCustom = mapAttrs
#     (n: v: prev.${n}.overrideAttrs (_: {
#       inherit (v) pname version src;
#     }))
#     (filterAttrs (_: v: isDerivation v) hyprland-pkgs);
# }

#   //
# {
#   hyprland = inputs.hyprland-hy3.inputs.hyprland.packages.${inputs.nixpkgs.system}.default;
#   hyprlandPlugins = prev.hyprlandPlugins // {
#     hy3 = inputs.hyprland-hy3.packages.default;
#   };
# }
