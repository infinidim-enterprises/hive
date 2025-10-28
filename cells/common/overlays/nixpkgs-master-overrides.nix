{ inputs, cell, ... }:
final: prev:
let
  nixpkgs-master = import inputs.nixpkgs-master {
    inherit (inputs.nixpkgs) system;
    config.allowUnfree = true;
  };
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
}
