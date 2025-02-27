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
      nixpkgs.nixpkgs-fmt
      nixpkgs.nodePackages.prettier
      nixpkgs.nodePackages.prettier-plugin-toml
      nixpkgs.shfmt
    ];
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
          options = [
            "--plugin"
            "${nixpkgs.nodePackages.prettier-plugin-toml}/lib/node_modules/prettier-plugin-toml/lib/index.js"
            "--write"
          ];
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
      builds.branch = "release";
      builds.include = [
        # "*.x86_64-linux.*"
        # TODO: aarch64-linux
        "devShells.aarch64-linux.*"
        "devShells.x86_64-linux.*"
        "packages.x86_64-linux.*"
        "nixosConfigurations.*"
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
            # filters.branches.only = [ "master" "auto/upgrade-dependencies" ];
            filters.tags.only = [ "/^damogran*/" ];
            filters.branches.ignore = [ "/.*/" ];
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
            "nix/install".channels = "nixpkgs=https://nixos.org/channels/nixos-24.11";
            "nix/install".extra-conf = ''
              experimental-features = nix-command flakes impure-derivations auto-allocate-uids cgroups
              system-features = nixos-test benchmark big-parallel kvm recursive-nix
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
              ./cells/repo/list-paths.sh > /tmp/store-path-pre-build
            '';
          }
          {
            run.name = "Build system";
            run.no_output_timeout = "55m";
            run.command = ''
              nix build --accept-flake-config ".#nixosConfigurations.<< parameters.host >>.config.system.build.toplevel"
            '';
          }
          {
            run.name = "Push cache";
            run.no_output_timeout = "55m";
            run.command = ''
              ./cells/repo/push-paths.sh cachix "--compression-method xz --compression-level 9 --jobs 4" njk ""  ""
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
      debug_steps = [
        {
          name = "✓ tmate.io session";
          uses = "mxschmitt/action-tmate@master";
          "if" = "\${{ failure() }}";
          "with" = {
            # detached = true;
            timeout-minutes = 10;
            limit-access-to-actor = true;
          };
        }
      ];

      common_steps = [
        {
          name = "⬆ Checkout";
          uses = "actions/checkout@v4.2.2";
        }
        {
          name = "✓ Install Nix";
          uses = "cachix/install-nix-action@v30";
          "with" = {
            nix_path = "nixpkgs=channel:nixos-24.11";
            extra_nix_config = ''
              access-tokens = github.com=''${{ secrets.GITHUB_TOKEN }}
              experimental-features = nix-command flakes impure-derivations auto-allocate-uids cgroups
              system-features = nixos-test benchmark big-parallel kvm recursive-nix
              download-buffer-size = 10485760
              accept-flake-config = true
            '';
          };
        }
        {
          name = "✓ Install cachix action";
          uses = "cachix/cachix-action@v15";
          "with" = {
            name = "njk";
            extraPullNames = "cuda-maintainers, mic92, nix-community, nrdxp";
            authToken = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
            signingKey = "\${{ secrets.CACHIX_SIGNING_KEY }}";
            cachixArgs = "--compression-method xz --compression-level 9 --jobs 4";
          };
        }
        {
          name = "✓ Free Disk Space";
          uses = "infinidim-enterprises/free-disk-space@master";
          "with" = {
            remove_android = true;
            remove_dotnet = true;
            remove_haskell = true;
            remove_docker_images = true;
            remove_tool_cache = true;
            remove_swap = true;
            remove_packages_one_command = true;
            remove_packages = lib.concatStringsSep " " [
              "heroku"
              "msodbcsql17"
              "mssql-tools"
              "python3-venv"
              "libjpeg-dev"
              "libjpeg8"
              "libjpeg8-dev"
              "linux-cloud-tools-azure"
              "linux-tools-azure"
              "libmagickcore-dev"
              "libmagickwand-dev"
              "python-is-python3"
              "r-recommended"
              "gfortran"
              "g++"
              "libc++-dev"
              "r-base-dev"
              "mime-support"
              "netcat"
              "dns-root-data"
              "libpthread-stubs0-dev"
              "python3-debconf"
              "tpm-udev"
              "tcl"
              "tk"
              "ruby-*"
              "rust*"
              "azure-cli"
              "google-*"
              "microsoft-*"
              "firefox*"
              "postgresql*"
              "mongo*"
              "php*"
              "temurin*"
              "llvm*"
              "mysql*"
              "dotnet*"
              "aspnet*"
              "docker*"
              "powershell*"
              "snapd"
              "aws-*"
            ];
            remove_folders = lib.concatStringsSep " " [
              "/etc/skel/.nvm"
              "/etc/skel/.dotnet"
              "/etc/skel/.cargo"
              "/etc/skel/.rustup"
              "/opt/microsoft"
              "/opt/pipx"
              "/home/runner/.nvm"
              "/home/runner/.dotnet"
              "/home/runner/.cargo"
              "/home/runner/.rustup"
              "/home/runneradmin/.nvm"
              "/home/runneradmin/.dotnet"
              "/home/runneradmin/.cargo"
              "/home/runneradmin/.rustup"
              "/home/linuxbrew"
              "/var/lib/postgresql"
              "/var/lib/gems"
              "/var/lib/mysql"
              "/var/lib/snapd"
              "/var/lib/docker*"

              "/usr/share/swift"
              "/usr/share/miniconda"
              "/usr/share/az*"
              "/usr/share/glade*"
              "/usr/share/ri"
              "/usr/share/kotlinc"
              "/usr/share/doc"
              "/usr/share/gradle*"
              "/usr/share/sbt"

              "/usr/src"
              "/usr/lib/R"
              "/usr/lib/snapd"
              "/usr/lib/python3"
              "/usr/lib/heroku"
              "/usr/lib/jvm"

              # "/usr/lib/x86_64-linux-gnu"
              # "/usr/lib/gcc"

              "/usr/local/n"
              "/usr/local/aws-sam-cli"
              "/usr/local/aws-cli"
              "/usr/local/julia1.11.3"
              # "/usr/local/bin"

              "/usr/local/lib/node_modules"

              "/usr/local/share/vcpkg"
              "/usr/local/share/chromium"
              "/usr/local/share/powershell"
            ];
            testing = false;
            # large-packages = true;
            # docker-images = true;
            # swap-storage = true;
          };
        }
      ];

      rpi4-damogran-linux = mkNixago {
        data = {
          name = "damogran [aarch64-linux]";
          on.push = null;
          on.workflow_dispatch = null;
          jobs = {
            build_damogran = {
              runs-on = "ubuntu-22.04-arm";
              steps = common_steps ++ [
                # {
                #   name = "Build damogran sdImage";
                #   run = ''nix build .#nixosConfigurations.nixos-damogran.config.system.build.sdImage'';
                # }

                {
                  name = "Build damogran toplevel";
                  run = ''nix build --accept-flake-config .#nixosConfigurations.nixos-damogran.config.system.build.toplevel'';
                }
              ] ++ debug_steps;
            };
          };
        };

        output = ".github/workflows/build-aarch64-damogran.yaml";
        format = "yaml";
        hook.mode = "copy";
      };

      devshell-multiarch-linux = mkNixago {
        data = {
          name = "devshell [aarch64-linux / x86_64-linux]";
          on.push = null;
          on.workflow_dispatch = null;
          jobs = {
            build_shell = {
              runs-on = "\${{ matrix.runs-on }}";
              strategy.matrix.include = [
                { runs-on = "ubuntu-22.04"; arch = "x86_64-linux"; }
                { runs-on = "ubuntu-22.04-arm"; arch = "aarch64-linux"; }
              ];
              steps = common_steps ++ [
                {
                  name = "Build devshell";
                  run = ''nix develop --accept-flake-config --command "menu"'';
                }
              ] ++ debug_steps;
            };
          };
        };

        output = ".github/workflows/build-devshell.yaml";
        format = "yaml";
        hook.mode = "copy";
      };

      # devshell-aarch64-linux = mkNixago {
      #   data = {
      #     name = "devshell [aarch64-linux]";
      #     on.push = null;
      #     on.workflow_dispatch = null;
      #     jobs = {
      #       build_shell = {
      #         runs-on = "ubuntu-22.04-arm";
      #         steps = common_steps ++ [
      #           {
      #             name = "Build devshell";
      #             run = ''nix develop --accept-flake-config --command "menu"'';
      #           }
      #         ] ++ debug_steps;
      #       };
      #     };
      #   };

      #   output = ".github/workflows/build-aarch64-devshell.yaml";
      #   format = "yaml";
      #   hook.mode = "copy";
      # };


      # devshell-x86_64-linux = mkNixago {
      #   data = {
      #     name = "devshell [x86_64-linux]";
      #     on.push = null;
      #     on.workflow_dispatch = null;
      #     jobs = {
      #       build_shell = {
      #         runs-on = "ubuntu-latest";
      #         steps = common_steps ++ [
      #           {
      #             name = "Build devshell";
      #             run = ''nix develop --accept-flake-config --command "menu"'';
      #           }
      #         ] ++ debug_steps;
      #       };
      #     };
      #   };

      #   output = ".github/workflows/build-x86_64-devshell.yaml";
      #   format = "yaml";
      #   hook.mode = "copy";
      # };

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
                run = ''nix build --accept-flake-config ".#nixosConfigurations.''${{ inputs.configuration }}.config.system.build.toplevel"'';
              }
            ] ++ debug_steps;
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
                nix develop --accept-flake-config '.#ci' --command bash -c "GITHUB_TOKEN=''${{ secrets.GITHUB_TOKEN }} update-cell-sources ALL"
                git commit -am "deps(sources): Updated cell sources"
              '';
            }
            {
              name = "Update flake.lock";
              uses = "DeterminateSystems/update-flake-lock@v24";
              "with".commit-msg = "deps(flake-lock): Updated flake.lock";
              "with".pr-title = "[Automated] Update 'flake.lock' and sources";
              "with".branch = "auto/upgrade-dependencies";
              "with".pr-labels = ''
                dependencies
                automated
              '';
            }
          ] ++ debug_steps;
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
                # NOTE: there's an alternative here: https://github.com/ncipollo/release-action
                name = "Release";
                uses = "softprops/action-gh-release@v2.2.1";
                "with" = {
                  files = ''/home/runner/work/_temp/iso_release/keygen-x86_64-linux.iso'';
                  tag_name = "v0.0.1";
                };
              }

            ] ++ debug_steps;
          };
        };
        output = ".github/workflows/keygen_iso_release.yaml";
        format = "yaml";
        hook.mode = "copy";
      };
    in
    [
      # NOTE: garnix builds most things now!
      # devshell-x86_64-linux
      # devshell-aarch64-linux
      devshell-multiarch-linux
      rpi4-damogran-linux
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
          topics = "nix, std, hive";
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
