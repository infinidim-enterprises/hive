{ inputs, cell, ... }:

{ self, config, osConfig, name, pkgs, lib, ... }:
let
  inherit (lib) mkMerge mkIf mkDefault;
  inherit (builtins) pathExists;
  inherit (pkgs) callPackage;

  doomCfgDir = "${self}/users/${name}/dotfiles/doom.d";
  doomCfgDirNix = "${doomCfgDir}/default.nix";
  doomCfgDirPkg = callPackage doomCfgDirNix { };

  emacs = pkgs.emacs29-pgtk; # TODO: pkgs.emacsPgtkGcc;
  extraPackages =
    let
      orgRoot = config.xdg.userDirs.documents + "/org";

      emacsPackages = pkgs.emacsPackagesFor emacs;
      localSetts = emacsPackages.trivialBuild rec {
        pname = "local-setts";
        ename = pname;
        version = "1.0";
        src = pkgs.writeText "local-setts.el" ''
          (defvar vod-setts-custom-from-nix "${pkgs.nodejs}/bin/node")

          (defun load-nix-setts ()
            (setq langtool-language-tool-server-jar "${pkgs.languagetool}/share/languagetool-server.jar"
                  plantuml-jar-path "${pkgs.plantuml}/lib/plantuml.jar"
                  org-plantuml-jar-path "${pkgs.plantuml}/lib/plantuml.jar"
                  org-directory "${orgRoot}"
                  org-brain-path "${orgRoot}/brain"
                  deft-directory "${orgRoot}/deft"
                  org-id-locations-file "${orgRoot}/.org-id-locations"
                  org-ref-pdf-directory "${orgRoot}/papers/pdf"
                  org-ref-bibliography-notes "${orgRoot}/papers/bib-notes.org"
                  org-ref-default-bibliography "${orgRoot}/papers/references.bib"
                  +snippets-dir "${config.xdg.userDirs.documents}/snippets"
                  url-history-file "${config.xdg.userDirs.extraConfig.XDG_LOGS_DIR}/emacs_url_hist.el"
                  savehist-file "${config.xdg.userDirs.extraConfig.XDG_LOGS_DIR}/emacs_save_hist.el"
                  sly-mrepl-history-file-name "${config.xdg.userDirs.extraConfig.XDG_LOGS_DIR}/sly-mrepl-history"))

          (provide 'local-setts)
        '';
      };
    in
    with emacsPackages; epkgs: [
      localSetts

      s
      sqlite3
      grab-x-link

      sly
      sly-asdf
      sly-overlay
      sly-quicklisp
      sly-macrostep
      sly-repl-ansi-color
      sly-named-readtables
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

  #   # TODO: http://aspell.net/0.50-doc/man-html/4_Customizing.html
  #   # home.file.".aspell.conf".text =
  #   #   ".aspell.conf".text = ''
  #   #   variety w_accents
  #   #   personal nc/config/aspell/en.pws
  #   #   repl nc/config/aspell/en.prepl
  #   # '';
  # }

  {
    programs.doom-emacs = {
      inherit emacs extraPackages;
      enable = mkDefault true;
      doomDir = mkDefault doomCfgDirPkg;
      doomLocalDir = mkDefault (
        config.xdg.dataHome + "/nix-doom-emacs-unstraightened"
      );
      extraBinPackages = [
        config.programs.ripgrep.package
        config.programs.git.package
        config.programs.fd.package
      ] ++ (with pkgs; [
        # org-mode helpers
        pandoc
        pandoc-imagine
        pandoc-plantuml-filter
        ditaa
        graphviz
        plantuml
        python3 # treemacs requirement
        bibtex2html

        (aspellWithDicts (dicts: with dicts; [
          en
          en-computers
          en-science
          de
          ru
        ]))
      ]);

    };

    services.emacs.enable = mkDefault true;
    services.emacs.client.enable = mkDefault true;
    services.emacs.defaultEditor = mkDefault true;

    systemd.user.services.emacs.Service.TimeoutStartSec = mkDefault 120;
  }

  # (mkIf ((!pathExists doomCfgDir) || !config.programs.doom-emacs.enable) {
  #   programs.emacs.enable = mkDefault true;
  #   programs.emacs.package = mkDefault pkgs.emacsPgtkNativeComp;
  #   # programs.emacs.extraPackages = mkDefault emacs_pkgs_fn;
  # })

  # (mkIf (pathExists doomCfgDir) {
  #   programs.doom-emacs.enable = mkDefault true;
  #   programs.doom-emacs.emacsPackage = mkDefault emacsPkg;
  #   # programs.doom-emacs.extraPackages = mkDefault emacs_pkgs;
  # })

  # (mkIf ((pathExists doomCfgDir) && (!pathExists doomCfgDirNix)) {
  #   programs.doom-emacs.doomPrivateDir = mkDefault doomCfgDir;
  # })

  # (mkIf ((pathExists doomCfgDir) && (pathExists doomCfgDirNix)) {
  #   programs.doom-emacs.doomPrivateDir = mkDefault (callPackage doomCfgDir { });
  # })
]
