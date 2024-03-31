{ inputs, cell, ... }:
let
  lib = inputs.nixpkgs-lib.lib // builtins;

  inherit (inputs) nixpkgs std;
  inherit (cell) config;

  nvfetcher = inputs.nvfetcher.packages.default;

  nixpkgs-master = import inputs.nixpkgs-master {
    inherit (inputs.nixpkgs) system;
    overlays = [ inputs.cells.common.overlays.vscode-extensions ];
    config.allowUnfree = true;
  };

  nixpkgs-unstable = import inputs.nixpkgs-unstable {
    inherit (inputs.nixpkgs) system;
    overlays = with inputs.cells.common.overlays; [ sources inputs.nur.overlay ];
    config.allowUnfree = true;
  };

  nixd = inputs.nixd.packages.default.override {
    inherit (inputs.nix4nixd.packages) nix;
  };

  vscode =
    let
      jsonFormat = nixpkgs.formats.json { };
      keybindings = jsonFormat.generate "vscode-keybindings.json" [
        {
          key = "tab";
          command = "emacs-tab.reindentCurrentLine";
          when = "editorTextFocus";
        }
      ];

      userSettings = jsonFormat.generate "vscode-user-settings.json" {
        "workbench.colorTheme" = "Solarized Dark";

        "fonted.font" = "UbuntuMono Nerd Font Mono";
        "editor.fontFamily" = "UbuntuMono Nerd Font Mono";
        "editor.fontSize" = 17;

        "emacs-mcx.strictEmacsMove" = false;
        "emacs-mcx.killRingMax" = 100;
        "emacs-mcx.cursorMoveOnFindWidget" = true;

        "editor.quickSuggestions".strings = true;
        "editor.formatOnPaste" = true;

        "shellformat.path" = lib.getExe nixpkgs.shfmt;
        "bashIde.shellcheckPath" = lib.getExe nixpkgs.shellcheck;

        "crystal-lang.compiler" = "${nixpkgs-unstable.crystal}/bin/crystal";
        "crystal-lang.server" = "${nixpkgs-unstable.crystalline}/bin/crystalline";
        "crystal-lang.shards" = "${nixpkgs-unstable.shards}/bin/shards";

        "nix.enableLanguageServer" = true;
        "nix.formatterPath" = lib.getExe nixpkgs-fmt;
        "nix.serverPath" = "${nixd}/bin/nixd";
        "nix.serverSettings" = {
          # nixd.eval = { };
          nixd.formatting.command = lib.getExe nixpkgs-fmt;
          nixd.options.enable = true;
        };
      };

      vscode-bin = nixpkgs-master.vscode-with-extensions.override {
        vscodeExtensions = with nixpkgs-master.vscode-extensions; [
          nix-ide

          bash-ide-vscode
          shell-format

          vscode-direnv
          gherkintablealign
          cucumberautocomplete

          fonted
          emacs-mcx
          vscode-emacs-tab

          remote-ssh-edit
          multi-cursor-case-preserve
        ];

      };

      bin = writeShellApplication {
        name = "code";
        runtimeInputs = with nixpkgs; [
          coreutils-full
          nodePackages.bash-language-server
        ];
        text = ''
          dataDir="''${XDG_CACHE_HOME}/vscode-devshell_user-data-dir"
          userDir="''${dataDir}/User"
          rm -rf "''${dataDir}"
          mkdir -p "''${userDir}"

          ln -s "${keybindings}" "''${userDir}/keybindings.json"
          ln -s "${userSettings}" "''${userDir}/settings.json"

          exec "${vscode-bin}/bin/code" --user-data-dir "''${dataDir}"
        '';
      };
    in
    bin;

  inherit
    (nixpkgs.appendOverlays [ inputs.cells.common.overlays.nixpkgs-unstable-overrides ])
    gnupg
    alejandra
    nixUnstable
    nixpkgs-fmt
    editorconfig-checker
    cachix
    nix-index
    statix

    act
    sops

    coreutils-full
    findutils
    bash
    gnused
    remarshal

    # (bundix.override { pkgs = nixpkgs-unstable; })

    /*
      {
      pkgs ? (import <nixpkgs> {}),
      ruby ? pkgs.ruby,
      bundler ? (pkgs.bundler.override { inherit ruby; }),
      nix ? pkgs.nix,
      nix-prefetch-git ? pkgs.nix-prefetch-git,
      }:
    */
    ;

  bundix = nixpkgs-unstable.bundix.override { pkgs = nixpkgs-unstable; };

  inherit
    (nixpkgs)
    writeShellApplication
    writeShellScriptBin
    writeScriptBin
    ;

  pkgWithCategory = category: package: { inherit package category; };
  nix = pkgWithCategory "nix";
  linter = pkgWithCategory "linter";
  docs = pkgWithCategory "docs";
  infra = pkgWithCategory "infra";
  ci = pkgWithCategory "ci";

  repl = writeShellScriptBin "repl" ''
    if [ -z "$1" ]; then
       ${nixpkgs.nixUnstable}/bin/nix repl --argstr host "$HOST" --argstr flakePath "$PRJ_ROOT" ${./_repl.nix} --show-trace
    else
       ${nixpkgs.nixUnstable}/bin/nix repl --argstr host "$HOST" --argstr flakePath $(readlink -f $1 | sed 's|/flake.nix||') ${./_repl.nix} --show-trace
    fi
  '';

  update-cell-sources = writeShellApplication {
    name = "update-cell-sources";
    runtimeInputs = with nixpkgs-unstable; [
      nixpkgs-fmt
      nvfetcher
      coreutils-full
      findutils
      bash
      gnused
      remarshal
      nur.repos.rycee.mozilla-addons-to-nix
    ];
    text = lib.fileContents ./_update-cell-sources.sh;
  };

  sops-reencrypt = writeScriptBin "sops-reencrypt" ''
    for filename in "$@"
    do
        ${sops}/bin/sops --decrypt --in-place $filename
        ${sops}/bin/sops --encrypt --in-place $filename
    done
  '';

in
lib.mapAttrs (_: std.lib.dev.mkShell) {
  default = {
    name = "infra";

    imports = [
      ./_sops.nix
      std.std.devshellProfiles.default
    ];

    nixago = config.githubworkflows ++
      [
        config.just
        config.conform
        config.treefmt
        config.editorconfig
        config.githubsettings
        config.lefthook
      ];

    packages = [
      gnupg
      vscode
    ];

    commands = [
      (nix nixUnstable)
      (nix cachix)
      (nix nix-index)
      (nix statix)

      (ci act)

      (infra sops)
      (infra inputs.nixos-generators.packages.nixos-generate)

      {
        category = "infra";
        name = "update-cell-sources";
        help = "Update cell package sources with nvfetcher";
        package = update-cell-sources;
      }

      {
        category = "infra";
        name = "sops-reencrypt";
        help = "Reencrypt sops-encrypted files";
        package = sops-reencrypt;
      }

      {
        category = "nix";
        name = "repl";
        help = "Start a nix repl with the flake loaded";
        package = repl;
      }

      (linter nixpkgs-fmt)
    ];
  };

  ci = {
    name = "ci";
    packages = [ update-cell-sources ];
  };
}
