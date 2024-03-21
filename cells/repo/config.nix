{ inputs, cell, ... }:
let
  inherit (inputs) std;
  inherit (std.lib.dev) mkNixago;
  lib = inputs.nixpkgs-lib.lib // builtins;
  nixpkgs = import inputs.nixpkgs-unstable {
    inherit (inputs.nixpkgs) system;
    config.allowUnfree = true;
  };

  hostsWithArch = arch: with lib;
    flatten (map
      (e: attrNames e)
      (map
        (cell: mapAttrs' (name: value: nameValuePair "${cell}-${name}" value)
          (filterAttrs (n: v: v.bee.system == arch)
            inputs.cells.${cell}.nixosConfigurations))
        (attrNames (filterAttrs (n: v: v ? nixosConfigurations) inputs.cells))));

  hostname = hostNameWithCell:
    with lib;
    let
      arr = splitString "-" hostNameWithCell;
    in
    removePrefix ((head arr) + "-") hostNameWithCell;

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

  garnix_io = mkNixago {
    data = {
      builds.include = [
        "devShells.x86_64-linux.ci" # FIXME: Change it back later
        # FIXME: "packages.x86_64-linux.*"
        # FIXME: "nixosConfigurations.*"
      ];
    };

    output = "garnix.yaml";
    format = "yaml";
    hook.mode = "copy";
  };

  circleci = mkNixago {
    data = {
      version = "2.1";
      workflows.version = "2";
      workflows.workflow.jobs = [
        {
          build = {
            filters.branches.only = [ "master" "auto/upgrade-dependencies" ];
            matrix.parameters.host = hostsWithArch "aarch64-linux";
          };
        }
      ];
      orbs.nix = "eld/nix@1.1.1";
      jobs.build = {
        machine.image = "ubuntu-2204:2023.07.1";
        parameters.host.type = "string";
        resource_class = "arm.large";
        steps = [
          {
            "nix/install".channels = "nixpkgs=https://nixos.org/channels/nixos-23.11";
            "nix/install".extra-conf = ''
              experimental-features = flakes nix-command
            '';
          }
          "nix/install-cachix"
          "checkout"
          {
            run.name = "Setup Cachix repos";
            run.command = ''
              cachix use nix-community
              cachix use mic92
              cachix use nrdxp
              cachix use njk
              ./.ci/install-nix.sh > /tmp/store-path-pre-build
            '';
          }
          {
            run.name = "Build system";
            run.command = ''
              nix build ".#nixosConfigurations.<< parameters.host >>.config.system.build.toplevel"
            '';
          }
          {
            run.name = "Push cache";
            run.no_output_timeout = "30m";
            run.command = ''
              ./.ci/push-paths.sh cachix "--compression-method xz --compression-level 9 --jobs 8" njk ""  ""
            '';
          }
        ];
      };
    };

    output = ".circleci/config.yml";
    format = "yaml";
    hook.mode = "copy";
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
          uses = "cachix/cachix-action@v14";
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

      workflowHostTemplate = mkNixago {
        data = {
          name = "Build x86_64 host";
          on.workflow_call.inputs.configuration = {
            required = true;
            type = "string";
          };
          on.workflow_call.secrets = {
            CACHIX_AUTH_TOKEN.required = true;
            CACHIX_SIGNING_KEY.required = true;
          };
          jobs.build_system = {
            runs-on = "ubuntu-latest";
            steps = common_steps ++ [
              {
                name = "Build system configuration";
                run = ''nix build ".#nixosConfigurations.''${{ inputs.configuration }}.config.system.build.toplevel"'';
              }
            ];
          };
        };

        output = ".github/workflows/build-x86_64-host.yaml";
        format = "yaml";
        hook.mode = "copy";
      };

      hostTemplate = host: {
        data = {
          name = "Build ${hostname host} [x86_64-linux]";
          on.push = null;
          on.workflow_dispatch = null;
          jobs = {
            call-workflow-passing-data = {
              uses = "./.github/workflows/build-x86_64-host.yaml";
              "with".configuration = "${host}";
              secrets = "inherit";
            };
          };
        };

        output = ".github/workflows/build-x86_64-${hostname host}.yaml";
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
            # {
            #   name = "Update deps hashes packages";
            #   run = ''
            #     nix run '.#mainsail.npmDepsHash' > cells/klipper/packages/_deps-hash/mainsail-npm.nix
            #     git commit -am "deps(sources): Updated deps hash" || true
            #   '';
            # }
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
            # schedule.time = "05:00";
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
                uses = "softprops/action-gh-release@v2.0.2";
                "with" = {
                  files = ''/home/runner/work/_temp/iso_release/keygen-x86_64-linux.iso'';
                  make_latest = "true";
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
      # NOTE: garnix builds most things now! devshell-x86_64-linux
      workflowHostTemplate
      flake-lock
      dependabot
      keygen_iso_release
    ];
  # NOTE: github doesn't build my hosts, because of the space constraints, over 50GB needed
  # and the runner doesn't have it
  # ++ (lib.map
  #   (host: mkNixago (hostTemplate host))
  #   (hostsWithArch "x86_64-linux"));

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
            scopes =
              [
                "ci"
                "flake"
              ]
              ++ (lib.attrNames inputs.cells.nixos.nixosConfigurations);
            # ++ (lib.attrNames inputs.cells.darwin.darwinConfigurations);
            descriptionLength = 72;
          };
        };
      };
    };

  # # Tool Homepage: https://rust-lang.github.io/mdBook/
  # mdbook = std.lib.cfg.mdbook {
  #   # add preprocessor packages here
  #   packages = [
  #     inputs.nixpkgs.mdbook-linkcheck
  #   ];
  #   data = {
  #     # Configuration Reference: https://rust-lang.github.io/mdBook/format/configuration/index.html
  #     book = {
  #       language = "en";
  #       multilingual = false;
  #       title = "CONFIGURE-ME";
  #       src = "docs";
  #     };
  #     build.build-dir = "docs/build";
  #     preprocessor = {};
  #     output = {
  #       html = {};
  #       # Tool Homepage: https://github.com/Michael-F-Bryan/mdbook-linkcheck
  #       linkcheck = {};
  #     };
  #   };
  #   output = "book.toml";
  #   hook.mode = "copy"; # let CI pick it up outside of devshell
  # };
}
