{ pkgs, profiles, ... }:
let
  # vodEmacsPkg = pkgs.emacs;
  vodEmacsPkg = pkgs.emacs-gtk; #.emacs29; #29-gtk3;
  vodEmacsExtraPkgs =
    let
      emacsPackages = pkgs.emacsPackagesFor vodEmacsPkg;

      customSetts = emacsPackages.trivialBuild rec {
        pname = "custom-setts-vod";
        ename = pname;
        version = "1.0";
        src = pkgs.writeText "custom-setts-vod.el" ''
          (defvar vod-setts-custom-from-nix "${pkgs.nodejs}/bin/node")
          (provide 'custom-setts-vod)
        '';
      };

      # lsp-install-servers = emacsPackages.trivialBuild {
      #   pname = "lsp-install-servers";
      #   version = "1.0";
      #   src = pkgs.writeText "lsp-install-servers.el" ''
      #     (eval-after-load 'lsp-mode
      #       '(progn
      #          (require 'lsp-javascript)
      #          (lsp-dependency 'typescript-language-server `(:system "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server"))
      #          (lsp-dependency 'typescript `(:system "${pkgs.nodePackages.typescript}/bin/tsserver"))))
      #   '';
      #   packageRequires = [ emacsPackages.lsp-mode ];
      # };
    in
    with emacsPackages; [
      customSetts

      s
      sqlite
      sqlite3
      # vterm
      # vterm-toggle
      grab-x-link
      # sly
      # sly-asdf
      # sly-macrostep
      # sly-named-readtables
      # sly-quicklisp
      # sly-repl-ansi-color
    ];
in

{
  imports = [ profiles.emacs ];

  # FIXME: programs.promnesia.enable = true;
  # programs.promnesia.configFile = ../dotfiles/promnesia/config.py;

  programs.doom-emacs.enable = true;
  programs.doom-emacs.emacsPackage = vodEmacsPkg;
  programs.doom-emacs.extraPackages = vodEmacsExtraPkgs;
  programs.doom-emacs.doomPrivateDir = pkgs.callPackage ../dotfiles/doom.d.nix { };
  programs.doom-emacs.emacsPackagesOverlay = self: super: {

    vterm = super.vterm.overrideAttrs (oldAttrs: {
      cmakeFlags = [
        "-DEMACS_SOURCE=${vodEmacsPkg.src}"
        "-DUSE_SYSTEM_LIBVTERM=ON"
      ];
    });

    org-pretty-table = self.trivialBuild {
      inherit (pkgs.sources-emacs.org-pretty-table) pname version src;
      ename = "org-pretty-table";
      packageRequires = with self; [ org ];
    };

    org-protocol-capture-html = self.trivialBuild {
      inherit (pkgs.sources-emacs.org-protocol-capture-html) pname version src;
      ename = "org-protocol-capture-html";
      buildInputs = with pkgs; [ pandoc curl ];
      packageRequires = with self; [ org s ];
    };

    # activity-watch-mode = self.trivialBuild {
    #   inherit (pkgs.sources-emacs.activity-watch-mode) pname version src;
    #   ename = "activity-watch-mode";
    #   packageRequires = with self; [ request cl-lib ];
    # };
    /*
      (require 'cl-lib)
      (require 'json)
      (require 'map)
      (require 'seq)
      (require 'subr-x)
      (require 'markdown-mode)
      (require 'diff)

    */
    lsp-bridge = self.trivialBuild rec {
      inherit (pkgs.sources-emacs.lsp-bridge) pname version src;
      ename = "lsp-bridge";
      buildInputs = with pkgs.python3Packages; [ epc orjson sexpdata six setuptools paramiko rapidfuzz ];
      packageRequires = with self; [ self.map markdown-mode ] ++ buildInputs;
    };

    copilot = self.trivialBuild {
      inherit (pkgs.sources-emacs.copilot-el) pname version src;
      ename = "copilot";
      buildInputs = with pkgs; [ nodejs ];
      packageRequires = with self; [ s dash editorconfig ];
    };

    color-rg = self.trivialBuild rec {
      inherit (pkgs.sources-emacs.color-rg) pname version src;
      ename = pname;
      buildInputs = with pkgs; [ ripgrep ];
    };

    nix-ts-mode = self.trivialBuild {
      inherit (pkgs.sources-emacs.nix-ts-mode) src pname version;
      # packageRequires = with self; [ emacs magit-section transient mmm-mode company ];
    };
  };

  home.sessionVariables.EMACS_PATH_COPILOT = "${pkgs.sources-emacs.copilot-el.src}";
  # ("voobscout^forge" for "api.github.com")

  home.file.".authinfo.gpg".source = ./authinfo.gpg;

  programs.chemacs.enable = false;

  ### FIXME: doomemacs doesn't recognize installed language servers.
  home.file."bin/json-ls".source = "${pkgs.nodePackages.vscode-json-languageserver-bin}/bin/json-languageserver";
  home.file."bin/html-ls".source = "${pkgs.nodePackages.vscode-html-languageserver-bin}/bin/html-languageserver";
  home.file."bin/css-ls".source = "${pkgs.nodePackages.vscode-css-languageserver-bin}/bin/css-languageserver";

  home.packages = with pkgs; [
    python3Packages.grip
    python3Full # treemacs seems to want that
    gnuplot

    openjdk11 # plantuml preview and friends
    nodejs # copilot seems to need it

    # Language servers
    nodePackages.yaml-language-server
    nodePackages.bash-language-server
    texlab # TeX language-server
    nodePackages.dockerfile-language-server-nodejs
    nodePackages.vscode-json-languageserver-bin
    nodePackages.vscode-css-languageserver-bin
    nodePackages.vscode-html-languageserver-bin
    ocamlPackages.digestif

    nodePackages.js-beautify
    nodePackages.stylelint
    tidyp
    html-tidy

    # (texlive.combine {
    #   inherit (texlive)
    #     # scheme-basic
    #     scheme-full
    #     xcolor
    #     xcolor-solarized
    #     koma-script
    #     koma-script-examples
    #     koma-script-sfs;
    # })
  ];

}
