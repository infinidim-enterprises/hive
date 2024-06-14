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

  nixpkgs-unstable = import inputs.nixpkgs-unstable {
    inherit (inputs.nixpkgs) system;
    overlays = with inputs.cells.common.overlays; [
      sources
      # crystal
    ];
    config.allowUnfree = true;
  };

  # crystal_fresh = import inputs.crystal-1_11_2_pr {
  #   inherit (inputs.nixpkgs) system;
  #   overlays = with inputs.cells.common.overlays; [ sources crystal ];
  #   config.allowUnfree = true;
  # };

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
          nixd.options.target.installable = ".#nixosConfigurations.nixos-oglaroon.options";
        };
      };

      vscode-bin = nixpkgs-master.vscode-with-extensions.override {
        vscodeExtensions = with nixpkgs-master.vscode-extensions; [
          nix-ide

          bash-ide-vscode
          shell-format

          crystal-lang

          gpt-pilot-vs-code

          vscode-direnv
          # FIXME: gherkintablealign
          cucumberautocomplete

          fonted
          emacs-mcx
          vscode-emacs-tab

          remote-ssh-edit
          gitlens
          multi-cursor-case-preserve
          /*
          TODO: check those out, maybe use some of them
        dbaeumer.vscode-eslint
        denoland.vscode-deno
        dhall.dhall-lang
        dhall.vscode-dhall-lsp-server
        editorconfig.editorconfig
        esbenp.prettier-vscode
        geequlim.godot-tools
        github.copilot
        github.vscode-github-actions
        gitlab.gitlab-workflow
        golang.go
        graphql.vscode-graphql-syntax
        gruntfuggly.todo-tree
        jock.svg
        leonardssh.vscord
        lunuan.kubernetes-templates
        mikestead.dotenv
        mkhl.direnv
        ms-kubernetes-tools.vscode-kubernetes-tools
        ms-vscode.live-server
        oscarotero.vento-syntax
        redhat.vscode-yaml
        ryanluker.vscode-coverage-gutters
        serayuzgur.crates
        tamasfe.even-better-toml
        tobermory.es6-string-html
        tomoki1207.pdf
        unifiedjs.vscode-mdx
        usernamehw.errorlens
        vscodevim.vim
        wakatime.vscode-wakatime
          */
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
    # nixUnstable
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

  repl =
    let
      nixBinary = nixpkgs.nixVersions.nix_2_18;
      # nixBinary = nixpkgs-unstable.nixUnstable;
      # NOTE: https://github.com/NixOS/nix/issues/8761
    in
    writeShellScriptBin "repl" ''
      if [ -z "$1" ]; then
         ${nixBinary}/bin/nix repl --argstr host "$HOST" --argstr flakePath "$PRJ_ROOT" ${./_repl.nix} --show-trace
      else
         ${nixBinary}/bin/nix repl --argstr host "$HOST" --argstr flakePath $(readlink -f $1 | sed 's|/flake.nix||') ${./_repl.nix} --show-trace
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
        config.dot_nixd_json
        # config.mdbook
      ];

    packages = [
      # nixpkgs-unstable.crystal
      # nixpkgs-unstable.crystalline
      # nixpkgs-unstable.shards
      nixpkgs-unstable.nixos-install-tools

      nvfetcher
      gnupg
      # vscode
    ];

    commands = [
      (nix nixpkgs-unstable.nixVersions.latest)
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

      # {
      #   category = "crypto-utils";
      #   inherit (ledger-live-desktop) name;
      #   help = ledger-live-desktop.meta.description;
      #   package = ledger-live-desktop;
      # }

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
