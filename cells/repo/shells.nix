{
  inputs,
  cell,
  ...
}: let
  lib = nixpkgs-lib.lib // builtins;

  inherit (inputs) nixpkgs nixpkgs-lib std latest;
  inherit (cell) config;
  inherit ((nixpkgs.appendOverlays [inputs.nur.overlay]).nur.repos.rycee) mozilla-addons-to-nix;

  inherit
    (inputs.cells.common.overrides)
    alejandra
    nixUnstable
    cachix
    nix-index
    statix
    nvfetcher
    act
    ;

  inherit
    (nixpkgs)
    sops
    editorconfig-checker
    mdbook
    gnupg
    writeShellApplication
    writeShellScriptBin
    writeScriptBin
    ;

  pkgWithCategory = category: package: {inherit package category;};
  nix = pkgWithCategory "nix";
  linter = pkgWithCategory "linter";
  docs = pkgWithCategory "docs";
  infra = pkgWithCategory "infra";
  ci = pkgWithCategory "ci";

  # export PATH=${inputs.latest.nixUnstable}/bin:$PATH
  repl = writeShellScriptBin "repl" ''
    if [ -z "$1" ]; then
       nix repl --argstr host "$HOST" --argstr flakePath "$PRJ_ROOT" ${./_repl.nix}
    else
       nix repl --argstr host "$HOST" --argstr flakePath $(readlink -f $1 | sed 's|/flake.nix||') ${./_repl.nix}
    fi
  '';

  update-cell-sources = writeShellApplication {
    name = "update-cell-sources";
    runtimeInputs = with nixpkgs; [
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

      nixago = [
        config.conform
        config.treefmt
        config.editorconfig
        config.githubsettings
        config.lefthook
        # config.mdbook
      ];

      packages = [
        nixUnstable
        gnupg
        update-cell-sources
      ];

      commands = [
        (nix nixUnstable)
        (nix cachix)
        (nix nix-index)
        (nix statix)

        (ci act)

        (infra sops)
        (infra inputs.colmena.packages.colmena)
        (infra inputs.home.packages.home-manager)
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

        {
          category = "nix";
          name = "build-on-target";
          help = "Helper script to build derivation on remote host";
          package = build-on-target;
        }

        (linter editorconfig-checker)
        (linter alejandra)

        (docs mdbook)
      ];
    };

    ci = {
      name = "ci";
      packages = [update-cell-sources];
    };
  }
