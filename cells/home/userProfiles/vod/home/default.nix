{ inputs, config, pkgs, profiles, suites, osConfig, lib, ... }:
with lib;
let
  isHiDpi = hasAttrByPath [ "deploy" "params" "hidpi" ] osConfig && osConfig.deploy.params.hidpi.enable;
in
{
  imports =
    # [ inputs.nix-doom-emacs.hmModule ] ++
    (inputs.cells.common.lib.importers.importFolder ./.) ++
    [
      # profiles.security.gpg
      # profiles.messengers
      # profiles.multimedia.players
      # profiles.pentester.traffic
      # profiles.security.keybase
      # profiles.security.password-store
      # # FIXME: profiles.activitywatch
      # profiles.browsers.firefox
      # profiles.browsers.floorp
    ] ++ (with profiles.developer; [
      # FIXME: extensions - vscode
      # ruby
      # nix
      # direnv
      # git
      # javascript
      # dbtools.postgresql
      # dbtools.mysql
      # tools
      # kubernetes
      # crystal
      # android
      # ballerina # NOTE: currently only java support
    ]);

  home.packages = with pkgs; [
    nyxt # TODO: nyxt proper config!
    tigervnc
    jekyll
    vultr-cli
    sops
  ];

  xdg.userDirs.extraConfig.XDG_PROJ_DIR = "${config.home.homeDirectory}/Projects";

  # NOTE: PASSWORD_STORE_KEY can use multiple fingerprints separated by a whitespace
  programs.password-store.settings.PASSWORD_STORE_KEY = "E3C4C12EDF24CA20F167CC7EE203A151BB3FD1AE 382A371CFB344166F69076BE8587AB791475DF76";

  services.gpg-agent.pinentryPackage = pkgs.pinentry-gnome3;
}
