{ inputs
, cell
, ...
}:
let
  inherit (inputs) nixpkgs nixpkgs-lib std;
  inherit (std.lib.dev) mkNixago;

  lib = nixpkgs-lib.lib // builtins;

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
      inputs.nixpkgs.nixpkgs-fmt
      inputs.nixpkgs.nodePackages.prettier
      inputs.nixpkgs.nodePackages.prettier-plugin-toml
      inputs.nixpkgs.shfmt
    ];
    devshell.startup.prettier-plugin-toml = inputs.nixpkgs.lib.stringsWithDeps.noDepEntry ''
      export NODE_PATH=${inputs.nixpkgs.nodePackages.prettier-plugin-toml}/lib/node_modules:''${NODE_PATH:-}
    '';
    data = {
      global.excludes = [ "cells/*/sources/generated.*" "cells/secrets/*" ];
      formatter = {
        nix = {
          command = "nixpkgs-fmt";
          includes = [ "*.nix" ];
        };
        prettier = {
          command = "prettier";
          options = [ "--plugin" "prettier-plugin-toml" "--write" ];
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
            "*.toml"
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
      commit-msg = {
        commands = {
          conform = {
            # allow WIP, fixup!/squash! commits locally
            run = ''
              [[ "$(head -n 1 {1})" =~ ^WIP(:.*)?$|^wip(:.*)?$|fixup\!.*|squash\!.* ]] ||
              conform enforce --commit-msg-file {1}'';
            skip = [ "merge" "rebase" ];
          };
        };
      };
      pre-commit = {
        skip = [
          { ref = "update_flake_lock_action"; }
        ];
        commands = {
          treefmt = {
            run = "treefmt --fail-on-change {staged_files}";
            skip = [ "merge" "rebase" ];
          };
        };
      };
    };
  };

  githubworkflows =
    let
      devshell-x86_64-linux = mkNixago {
        data = {
          name = "Build devshell [x86_64-linux]";
          on.push = null;
          on.workflow_dispatch = null;
          jobs = {
            build_shell = {
              runs-on = "ubuntu-latest";
              steps = [
                {
                  name = "Checkout repository";
                  uses = "actions/checkout@v4.1.1";
                }
                {
                  name = "Install Nix";
                  uses = "cachix/install-nix-action@v23";
                  "with" = {
                    nix_path = "nixpkgs=channel:nixos-23.05";
                    extra_nix_config = "access-tokens = github.com=\${{ secrets.GITHUB_TOKEN }}";
                  };
                }
                {
                  uses = "cachix/cachix-action@v12";
                  "with" = {
                    name = "njk";
                    extraPullNames = "cuda-maintainers, mic92, nix-community, nrdxp";
                    authToken = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
                    signingKey = "\${{ secrets.CACHIX_SIGNING_KEY }}";
                  };
                }
                {
                  name = "Build devshell";
                  run = ''nix develop --command "menu"'';
                }
              ];
            };
          };
        };

        output = ".github/workflows/build-x86-devshell.yaml";
        format = "yaml";
        hook.mode = "copy";
      };

      workflowHostTemplate = mkNixago {
        data = {
          name = "Build x86 host";
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
            steps = [
              {
                name = "Checkout repository";
                uses = "actions/checkout@v4.1.1";
              }
              {
                name = "Install Nix";
                uses = "cachix/install-nix-action@v23";
                "with".nix_path = "nixpkgs=channel:nixos-23.05";
                "with".extra_nix_config = "access-tokens = github.com=\${{ secrets.GITHUB_TOKEN }}";
              }
              {
                uses = "cachix/cachix-action@v12";
                "with".name = "njk";
                "with".extraPullNames = "cuda-maintainers, mic92, nix-community, nrdxp";
                "with".authToken = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
                "with".signingKey = "\${{ secrets.CACHIX_SIGNING_KEY }}";
              }
              {
                name = "Build system configuration";
                run = ''nix build ".#nixosConfigurations.''${{ inputs.configuration }}.config.system.build.toplevel"'';
              }
            ];
          };
        };

        output = ".github/workflows/build-x86-host_test.yaml";
        format = "yaml";
        hook.mode = "copy";
      };

      hostTemplate = host: {
        data = {
          name = "Build ${hostname host}";
          on.push = null;
          on.workflow_dispatch = null;
          jobs = {
            call-workflow-passing-data = {
              uses = "./.github/workflows/build-x86-host.yaml";
              "with".configuration = "${host}";
              secrets = "inherit";
            };
          };
        };

        output = ".github/workflows/build-x86-${hostname host}.yaml";
        format = "yaml";
        hook.mode = "copy";
      };

      flake-lock = mkNixago {
        data = {
          name = "Update flake.lock YAML_test";
          on.workflow_dispatch = null;
          on.schedule = [{ cron = "0 0 * * 6"; }];
          jobs.lockfile.runs-on = "ubuntu-latest";
          jobs.lockfile.steps = [
            {
              name = "Checkout repository";
              uses = "actions/checkout@v4.1.1";
            }
            {
              name = "Install Nix";
              uses = "cachix/install-nix-action@v23";
              "with".nix_path = "nixpkgs=channel:nixos-23.05";
              "with".extra_nix_config = "access-tokens = github.com=\${{ secrets.GITHUB_TOKEN }}";
            }
            {
              uses = "cachix/cachix-action@v12";
              "with".name = "njk";
              "with".extraPullNames = "cuda-maintainers, mic92, nix-community, nrdxp";
              "with".authToken = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
              "with".signingKey = "\${{ secrets.CACHIX_SIGNING_KEY }}";
            }
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
                nix develop '.#ci' --command bash -c "GITHUB_TOKEN=''${{ secrets.GITHUB_TOKEN }} update-cell-sources ALL
                git commit -am "deps(sources): Updated cell sources"
              '';
            }
            {
              name = "Update deps hashes packages";
              run = ''
                nix run '.#mainsail.npmDepsHash' > cells/klipper/packages/_deps-hash/mainsail-npm.nix
                git commit -am "deps(sources): Updated deps hash" || true
              '';
            }
            {
              name = "Update flake.lock";
              uses = "DeterminateSystems/update-flake-lock@v20";
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

        output = ".github/workflows/update-flake-lock.yaml";
        format = "yaml";
        hook.mode = "copy";
      };

    in
    [ devshell-x86_64-linux workflowHostTemplate flake-lock ]
    ++ (lib.map
      (host: mkNixago (hostTemplate host))
      (hostsWithArch "x86_64-linux"));

  # Tool Hompeage: https://github.com/apps/settings
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
          header = {
            length = 89;
            imperative = true;
          };
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
              ++ (lib.attrNames inputs.cells.nixos.nixosConfigurations)
              ++ (lib.attrNames inputs.cells.darwin.darwinConfigurations);
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
