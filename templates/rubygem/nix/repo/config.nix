{ inputs, cell, ... }:
let
  inherit (inputs) std;
  inherit (std.lib.dev) mkNixago;
  lib = inputs.nixpkgs-lib.lib // builtins;
  nixpkgs = import inputs.nixpkgs-unstable {
    inherit (inputs.nixpkgs) system;
    config.allowUnfree = true;
  };
in
{
  just = mkNixago std.lib.cfg.just {
    data.tasks = import ./justfile.nix { inherit inputs cell; };
  };

  editorconfig = mkNixago std.lib.cfg.editorconfig {
    data = {
      root = true;
      "*" = {
        end_of_line = "lf";
        insert_final_newline = true;
        trim_trailing_whitespace = true;
        charset = "utf-8";
        indent_style = "space";
        indent_size = 2;
      };
      "*.{diff,patch}" = {
        end_of_line = "unset";
        insert_final_newline = "unset";
        trim_trailing_whitespace = "unset";
        indent_size = "unset";
      };
      "*.md" = {
        max_line_length = "off";
        trim_trailing_whitespace = false;
      };
    };
  };

  # Tool Homepage: https://numtide.github.io/treefmt/
  treefmt = mkNixago std.lib.cfg.treefmt {
    packages = [
      # (nixpkgs.appendOverlays [inputs.cells.common.overlays.latest-overrides]).alejandra
      nixpkgs.nixpkgs-fmt
      nixpkgs.nodePackages.prettier
      # FIXME: nixpkgs.nodePackages.prettier-plugin-toml
      nixpkgs.shfmt
    ];
    # devshell.startup.prettier-plugin-toml = lib.stringsWithDeps.noDepEntry ''
    #   export NODE_PATH=${latest.nodePackages.prettier-plugin-toml}/lib/node_modules:''${NODE_PATH:-}
    # '';
    data = {
      global.excludes = [ "cells/*/sources/generated.*" "cells/secrets/*" ];
      formatter = {
        nix = {
          command = "nixpkgs-fmt";
          includes = [ "*.nix" ];
          excludes = [ "generated.nix" ];
        };
        prettier = {
          command = "prettier";
          options = [ "--write" ];
          # options = [ "--plugin" "prettier-plugin-toml" "--write" ];
          includes = [
            "*.css"
            "*.html"
            "*.js"
            "*.json"
            "*.jsx"
            "*.md"
            "*.mdx"
            "*.scss"
            "*.ts"
            "*.yaml"
            # "*.toml"
          ];
          excludes = [
            "test/*"
            "generated.json"
          ];
        };
        shell = {
          command = "shfmt";
          options = [ "-i" "2" "-s" "-w" ];
          includes = [ "*.sh" ];
        };
      };
    };
  };

  # Tool Homepage: https://github.com/evilmartians/lefthook
  #
  lefthook = mkNixago std.lib.cfg.lefthook {
    data = {
      commit-msg.commands.conform = {
        # allow WIP, fixup!/squash! commits locally
        run = ''
          [[ "$(head -n 1 {1})" =~ ^WIP(:.*)?$|^wip(:.*)?$|fixup\!.*|squash\!.* ]] ||
          conform enforce --commit-msg-file {1}'';
        skip = [ "merge" "rebase" ];
      };
      pre-commit = {
        skip = [{ ref = "update_flake_lock_action"; }];
        commands.treefmt.run = "treefmt --fail-on-change {staged_files}";
        commands.treefmt.skip = [ "merge" "rebase" ];
      };
    };
  };

  githubworkflows =
    let
      common_steps = [
        {
          name = "Checkout repository";
          uses = "actions/checkout@v4.1.2";
        }
        {
          name = "Install Nix";
          uses = "cachix/install-nix-action@v26";
          "with" = {
            nix_path = "nixpkgs=channel:nixos-23.11";
            extra_nix_config = "access-tokens = github.com=\${{ secrets.GITHUB_TOKEN }}";
          };
        }
        {
          name = "Install cachix action";
          uses = "cachix/cachix-action@v15";
          "with" = {
            name = "njk";
            extraPullNames = "cuda-maintainers, mic92, nix-community, nrdxp";
            authToken = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
            signingKey = "\${{ secrets.CACHIX_SIGNING_KEY }}";
          };
        }
        {
          name = "Free Disk Space";
          uses = "jlumbroso/free-disk-space@main";
          "with" = {
            tool-cache = true;
            android = true;
            dotnet = true;
            haskell = true;
            large-packages = true;
            docker-images = true;
            swap-storage = true;
          };
        }
      ];

      devshell-x86_64-linux = mkNixago {
        data = {
          name = "Build devshell [x86_64-linux]";
          on.push = null;
          on.workflow_dispatch = null;
          jobs = {
            build_shell = {
              runs-on = "ubuntu-latest";
              steps = common_steps ++ [
                {
                  name = "Build devshell";
                  run = ''nix develop --command "menu"'';
                }
              ];
            };
          };
        };

        output = ".github/workflows/build-x86_64-devshell.yaml";
        format = "yaml";
        hook.mode = "copy";
      };

      flake-lock = mkNixago {
        data = {
          name = "Update [flake.lock, nvfetcher sources]";
          on.workflow_dispatch = null;
          on.schedule = [{ cron = "0 0 * * 6"; }];
          jobs.lockfile.runs-on = "ubuntu-latest";
          jobs.lockfile.steps = common_steps ++ [
            {
              name = "Configure git";
              run = ''
                git config user.email "1203212+github-actions[bot]@users.noreply.github.com"
                git config user.name "github-actions[bot]"
              '';
            }
            {
              name = "Update nvfetcher packages";
              run = ''
                nix develop '.#ci' --command bash -c "GITHUB_TOKEN=''${{ secrets.GITHUB_TOKEN }} update-cell-sources ALL"
                git commit -am "deps(sources): Updated cell sources"
              '';
            }
            {
              name = "Update flake.lock";
              uses = "DeterminateSystems/update-flake-lock@v21";
              "with".commit-msg = "deps(flake-lock): Updated flake.lock";
              "with".pr-title = "[Automated] Update 'flake.lock' and sources";
              "with".branch = "auto/upgrade-dependencies";
              "with".pr-labels = ''
                dependencies
                automated
              '';
            }
          ];
        };

        output = ".github/workflows/update-flake.yaml";
        format = "yaml";
        hook.mode = "copy";
      };

      dependabot = mkNixago {
        data = {
          version = 2;
          updates = [{
            package-ecosystem = "github-actions";
            directory = "/";
            schedule.interval = "weekly";
            schedule.day = "saturday";
          }];
        };

        output = ".github/dependabot.yml";
        format = "yaml";
        hook.mode = "copy";
      };

      keygen_iso_release = mkNixago {
        data = {
          name = "Release keygen.iso [x86_64-linux]";
          # on.push = null;
          on.workflow_dispatch = null;
          jobs.build_and_release_iso = {
            runs-on = "ubuntu-latest";
            steps = common_steps ++ [
              {
                name = "Build keygen.iso";
                run = ''nix develop --accept-flake-config --command just release'';
              }
              {
                name = "copy iso";
                run = ''mkdir -p /home/runner/work/_temp/iso_release && cp $(cat /home/runner/work/_temp/iso_location.txt) /home/runner/work/_temp/iso_release/keygen-x86_64-linux.iso'';
              }
              {
                name = "Release";
                uses = "softprops/action-gh-release@v2.0.4";
                "with" = {
                  files = "/home/runner/work/_temp/iso_release/keygen-x86_64-linux.iso";
                  tag_name = "v0.0.1";
                };
              }

            ];
          };
        };
        output = ".github/workflows/keygen_iso_release.yaml";
        format = "yaml";
        hook.mode = "copy";
      };
    in
    [
      devshell-x86_64-linux
      flake-lock
      dependabot
      keygen_iso_release
    ];

  # Tool Homepage: https://github.com/apps/settings
  # Install Setting App in your repo to enable it
  githubsettings = mkNixago
    std.lib.cfg.githubsettings
    {
      data = {
        repository = {
          name = "hive";
          inherit (import (inputs.self + /flake.nix)) description;
          # homepage = "CONFIGURE-ME";
          topics = "nix, nixos, hive, flake, flakes, nix-flake, nix-flakes, haumea, colmena, std";
          default_branch = "master";
          allow_squash_merge = true;
          allow_merge_commit = true;
          allow_rebase_merge = false;
          delete_branch_on_merge = true;
          private = false;
          has_issues = false;
          has_projects = false;
          has_wiki = false;
          has_downloads = false;
        };
      };
    };

  conform = mkNixago
    std.lib.cfg.conform
    {
      data = {
        inherit (inputs) cells;
        commit = {
          header = { length = 89; imperative = true; };
          body.required = false;
          gpg.required = true;
          maximumOfOneCommit = false;
          conventional = {
            types = [
              "fix"
              "feat"
              "build"
              "chore"
              "ci"
              "docs"
              "style"
              "refactor"
              "test"
            ];
            scopes = [ "ci" "flake" ];
            descriptionLength = 72;
          };
        };
      };
    };
}
