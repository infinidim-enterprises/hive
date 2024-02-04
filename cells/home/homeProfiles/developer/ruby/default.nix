{ config, lib, pkgs, ... }:
with lib;
mkMerge [
  {
    home.packages = with pkgs; [
      bundix
      # vscode-bundlerEnv
      # (lib.lowPrio vscode-bundlerEnv.wrappedRuby)
    ];

    # TODO: GEM_HOME and GEM_PATH
    # home.sessionVariables.
  }

  (mkIf config.programs.vscode.enable
    {
      programs.vscode.extensions = with pkgs.vscode-extensions; [
        ruby-lsp
        # solargraph
        rails-snippets
        ruby-rubocop
        simple-ruby-erb
        ruby-linter
        ruby-symbols
        cucumberautocomplete
        gherkintablealign
      ];
    }
  )
]
