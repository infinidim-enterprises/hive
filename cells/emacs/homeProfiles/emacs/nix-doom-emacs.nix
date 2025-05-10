{ inputs, cell, ... }:

{ self, config, osConfig, name, pkgs, lib, ... }:
let
  inherit (lib) mkMerge mkIf mkDefault;
  inherit (builtins) pathExists;
  inherit (pkgs) callPackage;

  doomCfgDir = "${self}/users/${name}/dotfiles/doom.d";
  doomCfgDirNix = "${doomCfgDir}/default.nix";

  emacsPkg = pkgs.emacs; # TODO: pkgs.emacsPgtkGcc;

  emacs_pkgs = with pkgs; with (emacsPackagesFor emacsPkg).melpaPackages; [
    # vterm
    # vterm-toggle
    grab-x-link
    sly
    sly-asdf
    sly-macrostep
    sly-named-readtables
    sly-quicklisp
    sly-repl-ansi-color
  ];

  emacs_pkgs_fn = epkgs: with epkgs; [
    # vterm
    # vterm-toggle
    grab-x-link
    sly
    sly-asdf
    sly-macrostep
    sly-named-readtables
    sly-quicklisp
    sly-repl-ansi-color
  ];

in
mkMerge [
  (mkIf config.xdg.mimeApps.enable {
    home.packages = [ pkgs.wmctrl ];

    xdg.mimeApps.defaultApplications."x-scheme-handler/org-protocol" = "org-protocol.desktop";
    xdg.desktopEntries.org-protocol = {
      name = "org-protocol";
      exec = "emacsclient \"%u\"";
      terminal = false;
      icon = "emacs";
      type = "Application";
      comment = "org-capture";
      categories = [ "Utility" "System" ];
      mimeType = [ "x-scheme-handler/org-protocol" ];
    };
  })

  (mkIf config.xdg.enable {

    xdg.userDirs.extraConfig = {
      EMACS_PATH_SNIPPETS_DIR = "$HOME/Documents/snippets";
      EMACS_PATH_ORG = "$HOME/Documents/org";
      EMACS_PATH_ORG_BRAIN = "$HOME/Documents/org/brain";
      EMACS_PATH_ORG_DEFT = "$HOME/Documents/org/deft";
      EMACS_PATH_ORG_PAPERS = "$HOME/Documents/org/papers";
      EMACS_PATH_ORG_REF_PDF_DIRECTORY = "$HOME/Documents/org/papers/pdf";
    };

    home.sessionVariables = {
      EMACS_PATH_LANGTOOL_SERVER = "${pkgs.languagetool}/share/languagetool-server.jar";
      EMACS_PATH_PLANTUML = "${pkgs.plantuml}/lib/plantuml.jar";
      EMACS_PATH_ORG_ID_LOCATION = "$EMACS_PATH_ORG/.org-id-locations";
      EMACS_PATH_ORG_REF_BIBLIOGRAPHY_NOTES = "$EMACS_PATH_ORG_PAPERS/bib-notes.org";
      EMACS_PATH_ORG_REF_DEFAULT_BIBLIOGRAPHY = "$EMACS_PATH_ORG_PAPERS/references.bib";
    };

  })

  {
    home.packages = [
      (pkgs.aspellWithDicts (dicts: with dicts; [
        en
        en-computers
        en-science
        de
        ru
      ]))
    ];

    # TODO: http://aspell.net/0.50-doc/man-html/4_Customizing.html
    # home.file.".aspell.conf".text =
    #   ".aspell.conf".text = ''
    #   variety w_accents
    #   personal nc/config/aspell/en.pws
    #   repl nc/config/aspell/en.prepl
    # '';
  }

  {
    services.emacs.enable = mkDefault true;
    services.emacs.client.enable = mkDefault true;
    services.emacs.defaultEditor = mkDefault true;
    systemd.user.services.emacs.Service.TimeoutStartSec = mkDefault 120;
    home.packages = with pkgs; [
      # org-mode helpers
      pandoc
      pandoc-imagine
      pandoc-plantuml-filter
      ditaa
      graphviz
      plantuml
      bibtex2html
    ];
  }

  (mkIf ((!pathExists doomCfgDir) || !config.programs.doom-emacs.enable) {
    programs.emacs.enable = mkDefault true;
    programs.emacs.package = mkDefault pkgs.emacsPgtkNativeComp;
    programs.emacs.extraPackages = mkDefault emacs_pkgs_fn;
  })

  (mkIf (pathExists doomCfgDir) {
    programs.doom-emacs.enable = mkDefault true;
    programs.doom-emacs.emacsPackage = mkDefault emacsPkg;
    programs.doom-emacs.extraPackages = mkDefault emacs_pkgs;
  })

  (mkIf ((pathExists doomCfgDir) && (!pathExists doomCfgDirNix)) {
    programs.doom-emacs.doomPrivateDir = mkDefault doomCfgDir;
  })

  (mkIf ((pathExists doomCfgDir) && (pathExists doomCfgDirNix)) {
    programs.doom-emacs.doomPrivateDir = mkDefault (callPackage doomCfgDir { });
  })
]

# xresources.properties = {
#   "Emacs.menuBar" = "off";
#   "Emacs.verticalScrollBars" = "off";
#   "Emacs.toolBar" = "off";
#   "Emacs.fullscreen" = "maximized";
# };
