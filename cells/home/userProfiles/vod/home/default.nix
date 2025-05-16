{ inputs
, config
, pkgs
, profiles
  # , suites
, localLib
, osConfig
, lib
, ...
}:
let
  inherit (lib // builtins)
    mkMerge
    mkIf
    concatStringsSep;
  inherit (localLib) isGui;

  PASSWORD_STORE_KEY = concatStringsSep " " [
    # NOTE: PASSWORD_STORE_KEY can use multiple fingerprints separated by a whitespace
    # NOTE: [no longer using it] "E3C4C12EDF24CA20F167CC7EE203A151BB3FD1AE" # yubikey
    "382A371CFB344166F69076BE8587AB791475DF76" # nitrokey
  ];
in
{
  imports =
    # (inputs.cells.common.lib.importers.importFolder ./.) ++
    [
      ./ssh.nix
      ./waveterm.nix
      ./ghostty.nix
      ./gitconfig.nix
      ./emacs-unstraightened.nix

      # profiles.security.gpg
      # profiles.messengers
      # profiles.multimedia.players
      # profiles.pentester.traffic
      # profiles.security.keybase
      # profiles.security.password-store
      # profiles.browsers.firefox
      # profiles.browsers.floorp
    ] ++ (with profiles.developer; [
      # ruby
      # nix
      # direnv
      # git
      javascript
      dbtools.postgresql
      # dbtools.mysql
      # tools
      # kubernetes
      # crystal
      # android
      # ballerina # NOTE: currently only java support
    ]);

  config = mkMerge [
    (mkIf (isGui osConfig) {
      xdg.configFile."nyxt".source = ../dotfiles/nyxt;
      xdg.configFile."nyxt".recursive = true;
      # xdg.configFile."common-lisp/asdf-output-translations.conf.d/99-disable-cache.conf".text = ":disable-cache";

      home.packages = with pkgs; [
        httpie-desktop # Painlessly test REST, GraphQL, and HTTP APIs
        tigervnc
        ventoy-full
      ];
    })

    (mkIf (isGui osConfig && config.gtk.enable) {
      gtk.gtk3.bookmarks = [
        "file:///home/vod/Documents/%D0%9A%D0%B0%D1%82%D1%8F"
        "file:///home/vod/Projects/insurance-agent/out IA out"
        "smb://admin@damogran.njk.local/media media"
      ];
    })

    {
      programs.password-store.settings = { inherit PASSWORD_STORE_KEY; };
      xdg.userDirs.extraConfig.XDG_PROJ_DIR = "${config.home.homeDirectory}/Projects";

      home.file.".authinfo.gpg".source = ./authinfo.gpg;

      home.packages = with pkgs; [
        swagger-codegen # Generate stuff from openAPI spec [ CLI tool ]

        sops

        google-cloud-sdk
        vultr-cli
        oci-cli

        inputs.cells.common.packages.zerotierone
      ];
    }
  ];

}
