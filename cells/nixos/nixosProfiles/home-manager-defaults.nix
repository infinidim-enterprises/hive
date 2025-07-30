{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
{
  # NOTE: at some point NixOS started doing it
  # environment.loginShellInit = ''
  #   [ -r $HOME/.profile ] && . $HOME/.profile || true
  # '';

  programs.fuse.userAllowOther = true; # NOTE: needed for impermanence in home-manager
  programs.command-not-found.enable = true; # to use the home-manager version

  environment.homeBinInPath = true;
  users.mutableUsers = lib.mkDefault false;

  home-manager.verbose = false; # DEBUG disabled!
  home-manager.sharedModules =
    [
      {
        programs.starship.enable = true;
        programs.command-not-found.enable = !config.programs.command-not-found.enable;

        home.sessionVariables.HM_FONT_NAME = "UbuntuMono Nerd Font Mono";
        home.sessionVariables.HM_FONT_SIZE = "15";
      }

      ({ config, osConfig, ... }:
        lib.mkIf config.xdg.enable
          {
            xdg.userDirs.extraConfig.XDG_LOGS_DIR = "${config.home.homeDirectory}/Logs";
            xdg.userDirs.extraConfig.XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/screenshots";
            xdg.configFile."nix/registry.json".text = osConfig.environment.etc."nix/registry.json".text;
          })
    ];
}
