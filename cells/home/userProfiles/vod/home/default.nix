{ inputs, config, pkgs, profiles, suites, osConfig, lib, ... }:
let
  inherit (lib // builtins)
    mkMerge
    mkIf
    concatStringsSep;

  PASSWORD_STORE_KEY = concatStringsSep " " [
    # NOTE: PASSWORD_STORE_KEY can use multiple fingerprints separated by a whitespace
    "E3C4C12EDF24CA20F167CC7EE203A151BB3FD1AE" # yubikey
    "382A371CFB344166F69076BE8587AB791475DF76" # nitrokey
  ];
in
{
  imports =
    # (inputs.cells.common.lib.importers.importFolder ./.) ++
    [
      ./ssh.nix
      ./waveterm.nix
      ./gitconfig.nix
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
      dbtools.postgresql
      # dbtools.mysql
      # tools
      # kubernetes
      # crystal
      # android
      # ballerina # NOTE: currently only java support
    ]);

  config = mkMerge [
    {
      programs.password-store.settings = { inherit PASSWORD_STORE_KEY; };
      xdg.userDirs.extraConfig.XDG_PROJ_DIR = "${config.home.homeDirectory}/Projects";

      home.packages = with pkgs; [
        tigervnc
        waveterm # AI assisted GUI terminal

        httpie-desktop # Painlessly test REST, GraphQL, and HTTP APIs

        sops

        google-cloud-sdk
        vultr-cli
        oci-cli

        ventoy-full

        inputs.cells.common.packages.zerotierone
      ];
    }

    (mkIf config.gtk.enable {
      gtk.gtk3.bookmarks = [
        "file:///home/vod/Documents/%D0%9A%D0%B0%D1%82%D1%8F"
        "file:///home/vod/Projects/insurance-agent/out IA out"
      ];
    })
  ];

}
