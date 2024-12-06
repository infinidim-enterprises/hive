{ inputs, config, pkgs, profiles, suites, osConfig, lib, ... }:
with lib;
let
  isHiDpi = hasAttrByPath [ "deploy" "params" "hidpi" ] osConfig && osConfig.deploy.params.hidpi.enable;
  keys = [
    "E3C4C12EDF24CA20F167CC7EE203A151BB3FD1AE" # yubikey
    "382A371CFB344166F69076BE8587AB791475DF76" # nitrokey
  ];
  # NOTE: PASSWORD_STORE_KEY can use multiple fingerprints separated by a whitespace
  PASSWORD_STORE_KEY = concatStringsSep " " keys;
in
{
  imports =
    # (inputs.cells.common.lib.importers.importFolder ./.) ++
    [
      ./gitconfig.nix
      ./ssh.nix
      ./emacs-unstraightened.nix

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

  config = mkMerge [
    {
      xdg.userDirs.extraConfig.XDG_PROJ_DIR = "${config.home.homeDirectory}/Projects";

      home.packages = with pkgs; [
        tigervnc
        jekyll
        vultr-cli
        sops
      ];

      programs.password-store.settings = { inherit PASSWORD_STORE_KEY; };
      # services.gpg-agent.pinentryPackage = pkgs.pinentry-gnome3;
    }

    (mkIf config.gtk.enable {
      gtk.gtk3.bookmarks = [
        "file:///home/vod/Documents/%D0%9A%D0%B0%D1%82%D1%8F"
        "file:///home/vod/Projects/insurance-agent/out IA out"
      ];
    })
  ];

}
