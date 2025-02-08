{ inputs, cell, ... }:

{
  # NOTE: this a dummy config to let nixd use home options
  nixd = rec {
    bee.system = "x86_64-linux";
    bee.home = inputs.home-unstable;
    bee.pkgs = import inputs.nixpkgs-unstable {
      inherit (bee) system;
      config.allowUnfree = true;
    };

    home.username = "nixd";
    home.stateVersion = "25.05";
    home.homeDirectory = "/home/nixd";
    home.enableNixpkgsReleaseCheck = false;
  };
}
