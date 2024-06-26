{ osConfig, config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    mkMerge
    hasAttr;
in
mkMerge [
  (mkIf
    (
      config.services.emacs.enable
      || (hasAttr "doom-emacs" config.programs && config.programs.doom-emacs.enable)
      || config.programs.emacs.enable
    )

    {
      home.packages = with pkgs;
        [
          tree-sitter
          tree-sitter-grammars.tree-sitter-nix
        ];
    })

  (lib.mkIf config.programs.zsh.enable {
    programs.zsh.enableCompletion = true; # installs pkgs.nix-zsh-completions
    programs.zsh.plugins = [
      {
        name = "nix-zsh-completions";
        file = "share/zsh/plugins/nix/nix-zsh-completions.plugin.zsh";
        src = pkgs.nix-zsh-completions;
      }

      {
        name = "zsh-nix-shell";
        file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
        src = pkgs.zsh-nix-shell;
      }
    ];

    programs.zsh.profileExtra = ''
      nix-path() {
        readlink -f $(which $1)
      }

      nix-remove-home-roots() {
        nix-store --gc --print-roots | grep -i $HOME | cut -d ' ' -f 1 | xargs rm
      }
    '';
  })

  (mkIf config.programs.vscode.enable {
    programs.vscode.userSettings."nix.enableLanguageSupport" = true;
    programs.vscode.userSettings."nix.formatterPath" = "alejandra";
    programs.vscode.userSettings."nix.serverPath" = "nixd";
    programs.vscode.userSettings."nix.serverSettings" = {
      "nixd" = {
        "eval" = { };
        "formatting" = { "command" = "alejandra"; };
        "options" = {
          "enable" = true;
          "target" = {
            "args" = [ ];
            "installable" = "<flakeref>#nixosConfigurations.<name>.options";
            # "installable" = "<flakeref>#debug.options";
            # "installable" = "<flakeref>#homeConfigurations.<name>.options";
          };
        };
      };
    };
    # {
    #   "nixd" = {
    #     "formatting" = { "command" = "alejandra"; };
    #     "options" = {
    #       "enable" = true;
    #       "target" = { "installable" = "<flakeref>#nixosConfigurations.<name>.options"; };
    #     };
    #   };
    # };

    programs.vscode.extensions = with pkgs.vscode-extensions; [
      nix-ide
      # FIXME: [login issues] codium
    ];
  })

  {
    home.packages = with pkgs; [
      niv
      nurl
      dconf2nix
      nix-bundle
      nix-diff
      # FIXME: nix-du
      nix-index
      nix-info
      # nix-plugins doesn't build with currently latest nix 2.6
      nix-prefetch
      nix-prefetch-scripts
      nix-prefetch-github
      nix-prefetch-docker
      nix-script
      nix-template
      # FIXME: nix-template-rpm
      dpkg
      nix-top
      nix-tree
      nix-universal-prefetch
      nix-update
      nix-update-source
      nixbang
      nixos-shell
      cached-nix-shell
      nixpkgs-fmt
      nixfmt-classic
      # nixfmt-rfc-style
      nixpkgs-review
      # NOTE: broken nix-linter
      cachix
      # LSP
      nixd
      alejandra
    ];

    services.lorri.enable = true;
    systemd.user.services.lorri.Service.Environment =
      let
        path = with pkgs; lib.makeSearchPath "bin" [
          osConfig.nix.package
          gitMinimal
          gnutar
          xz
          gzip
          pigz
        ];
      in
      [ "PATH=${path}" ];
  }
]

# "NIX_PATH=${concatStringsSep ":" nixPath}"
# maybe use it instead of lorri
# programs.direnv.enableNixDirenvIntegration = true;
# there's also this: https://github.com/xzfc/cached-nix-shell
