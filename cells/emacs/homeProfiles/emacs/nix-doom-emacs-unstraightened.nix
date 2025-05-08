{ ... }:

{ self
, config
  # , osConfig
, name
, pkgs
, lib
, ...
}:
let
  inherit (lib) mkMerge mkIf mkDefault;
  inherit (pkgs) callPackage;
  extraBinPackages = [
    config.programs.ripgrep.package
    config.programs.git.package
    config.programs.fd.package
  ] ++ (with pkgs; [

    emacsclient-commands

    aider-chat

    (sbcl.withPackages (p: with p; [
      slynk
      slynk-macrostep
      slynk-named-readtables
    ]))

    # org-mode helpers
    pandoc
    pandoc-imagine
    pandoc-plantuml-filter

    ditaa # Convert ascii art diagrams into proper bitmap graphics
    graphviz # Graph visualization tools
    plantuml # Draw UML diagrams using a simple and human readable text descriptio
    d2 # Modern diagram scripting language that turns text to diagrams
    python3 # treemacs requirement
    bibtex2html

    semgrep
    bash-language-server
    yaml-language-server

    curl

    (aspellWithDicts (dicts: with dicts; [
      en
      en-computers
      en-science
      de
      ru
    ]))
  ]);

  doomCfgDir = "${self}/users/${name}/dotfiles/doom.d";
  doomCfgDirNix = "${doomCfgDir}/default.nix";
  doomCfgDirPkg = callPackage doomCfgDirNix { };

  emacs = pkgs.emacs-pgtk; # pkgs.emacs29-pgtk; # TODO: pkgs.emacsPgtkGcc;
  extraPackages =
    let
      orgRoot = config.xdg.userDirs.documents + "/org";

      emacsPackages = pkgs.emacsPackagesFor emacs;
      localSetts = emacsPackages.trivialBuild rec {
        pname = "local-setts";
        ename = pname;
        version = "1.0";
        # TODO: user-full-name "John Doe"
        # TODO: user-mail-address "john@doe.com"

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
      treesit-grammars.with-all-grammars
      localSetts

      # ISSUE: https://github.com/marienz/nix-doom-emacs-unstraightened?tab=readme-ov-file#tree-sitter-error-on-initialization-with-file-error-opening-output-file-read-only-file-system

      dired-hacks-utils
      f
      s

      sqlite3
      grab-x-link

      # sly
      # sly-asdf
      # sly-overlay
      # sly-quicklisp
      # sly-macrostep
      # sly-repl-ansi-color
      # sly-named-readtables
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
    home.packages = extraBinPackages;

    programs.doom-emacs = {
      inherit emacs extraPackages;
      enable = mkDefault true;
      doomDir = mkDefault doomCfgDirPkg;
      doomLocalDir = mkDefault (
        config.xdg.dataHome + "/nix-doom-emacs-unstraightened"
      );
      # TODO: experimentalFetchTree osConfig.nix.package.version
      # ISSUE: https://github.com/marienz/nix-doom-emacs-unstraightened/issues/14
      experimentalFetchTree = true;
      # FIXME: programs.doom-emacs.extraBinPackages | doesn't work on 24.11 release
      inherit extraBinPackages;
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
