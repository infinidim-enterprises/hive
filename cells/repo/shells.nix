{ inputs, cell, ... }:
let
  lib = inputs.nixpkgs-lib.lib // builtins;

  inherit (inputs) nixpkgs std;
  inherit (cell) config;
  inherit ((nixpkgs.appendOverlays [ inputs.nur.overlay ]).nur.repos.rycee) mozilla-addons-to-nix;

  nvfetcher = inputs.nvfetcher.packages.default;
  ssh-to-pgp = inputs.sops-ssh-to-pgp.packages.default;
  ssh-to-age = inputs.sops-ssh-to-age.packages.default;

  nixpkgs-master = import inputs.nixpkgs-master {
    inherit (inputs.nixpkgs) system;
    overlays = [ inputs.cells.common.overlays.vscode-extensions ];
    config.allowUnfree = true;
  };
  /*
    { pkgs ? import <nixpkgs> { } }:
    with pkgs;
    let
    codium = vscode-with-extensions.override {
    vscode = vscodium;
    vscodeExtensions = with vscode-extensions; [
      jnoortheen.nix-ide
    ];
    };
    in
    writeShellScriptBin "codium-test" ''
    set -e
    dir="''${XDG_CACHE_HOME:-~/.cache}/nixd-codium"
    ${coreutils}/bin/mkdir -p "$dir/User"
    cat >"$dir/User/settings.json" <<EOF
    {
    "security.workspace.trust.enabled": false,
    "nix.enableLanguageServer": true,
    "nix.serverPath": "nixd",
    }
    EOF
    ${codium}/bin/codium --user-data-dir "$dir" "$@"
    ''
  */

  nixd = inputs.nixd.packages.default.override {
    inherit (nixpkgs) nix;
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

        "editor.fontFamily" = "UbuntuMono Nerd Font Mono";
        "editor.fontSize" = 15;

        "emacs-mcx.strictEmacsMove" = false;
        "emacs-mcx.killRingMax" = 100;
        "emacs-mcx.cursorMoveOnFindWidget" = true;

        "editor.quickSuggestions".strings = true;
        "editor.formatOnPaste" = true;

        "shellformat.path" = lib.getExe nixpkgs.shfmt;
        "bashIde.shellcheckPath" = lib.getExe nixpkgs.shellcheck;

        "nix.enableLanguageServer" = true;
        "nix.formatterPath" = lib.getExe nixpkgs-fmt;
        "nix.serverPath" = "${nixd}/bin/nixd";
        "nix.serverSettings" = {
          # nixd.eval = { };
          nixd.formatting.command = lib.getExe nixpkgs-fmt;
          nixd.options.enable = true;
          nixd.options.target.installable = ".#nixosConfigurations.nixos-oglaroon.options";
        };
      };

      vscode-bin = nixpkgs-master.vscode-with-extensions.override {
        vscodeExtensions = with nixpkgs-master.vscode-extensions; [
          nix-ide

          vscode-direnv
          gherkintablealign
          cucumberautocomplete

          bash-ide-vscode
          shell-format

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

  inherit (nixpkgs-master)
    ledger-live-desktop;

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
    ;

  inherit
    (nixpkgs)
    mdbook
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
    runtimeInputs = [
      # alejandra
      nixpkgs-fmt
      nvfetcher
      coreutils-full
      findutils
      bash
      gnused
      remarshal
      mozilla-addons-to-nix
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

  build-on-target = writeScriptBin "build-on-target" ''
    set -e -o pipefail

    show_usage() {
      echo "$0 --attr <flake attr to build> --remote <ssh remote address>"
    }

    flakeFlags=(--extra-experimental-features 'nix-command flakes')
    to="$PWD/result"

    while [ "$#" -gt 0 ]; do
      i="$1"; shift 1

      case "$i" in
        --attr)
          attr="$1"
          shift 1
          ;;

        --remote)
          buildHost="$1"
          shift 1
          ;;

        --to)
          to="$1"
          shift 1
          ;;

        *)
          echo "$0: unknown option \`$i'"
          show_help
          exit 1
          ;;
      esac
    done

    # Eval derivation
    echo evaluating...
    drv="$(nix "''${flakeFlags[@]}" eval --raw "''${attr}.drvPath")"

    # Copy derivation to target
    echo copying to target...
    NIX_SSHOPTS=$SSHOPTS nix "''${flakeFlags[@]}" copy --substitute-on-destination --derivation --to "ssh://$buildHost" "$drv"

    # Build derivation on target
    echo build on target...
    ssh $SSHOPTS "$buildHost" sudo -- nix-store --realise "$drv" "''${buildArgs[@]}"

    # Copy result from target
    echo copying from target...
    NIX_SSHOPTS=$SSHOPTS nix copy --no-check-sigs --to "$to" --from "ssh://$buildHost" "$drv"
  '';
in
lib.mapAttrs (_: std.lib.dev.mkShell) {
  default = {
    name = "infra";

    imports = [
      ./_sops.nix
      std.std.devshellProfiles.default
    ];

    nixago =
      config.githubworkflows
      ++ [
        config.just
        config.conform
        config.treefmt
        config.editorconfig
        config.githubsettings
        config.lefthook
        config.circleci
        config.garnix_io
        # config.mdbook
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
      (infra inputs.colmena.packages.colmena)
      # (infra inputs.home.packages.home-manager)
      (infra inputs.nixos-generators.packages.nixos-generate)
      (infra ssh-to-pgp)
      (infra ssh-to-age)

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
        category = "crypto-utils";
        inherit (ledger-live-desktop) name;
        help = ledger-live-desktop.meta.description;
        package = ledger-live-desktop;
      }

      {
        category = "nix";
        name = "repl";
        help = "Start a nix repl with the flake loaded";
        package = repl;
      }

      # {
      #   category = "nix";
      #   name = "build-on-target";
      #   help = "Helper script to build derivation on remote host";
      #   package = build-on-target;
      # }

      # (linter editorconfig-checker)
      (linter nixpkgs-fmt)

      (docs mdbook)
    ];
  };

  ci = {
    name = "ci";
    packages = [ update-cell-sources ];
  };
}
