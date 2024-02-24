{
  description = "The Hive - VoD systems";
  # Cachix
  nixConfig.extra-substituters = [
    "https://njk.cachix.org"
    "https://cache.garnix.io"
  ];
  nixConfig.extra-trusted-public-keys = [
    "njk.cachix.org-1:ON4lemYq096ZfK5MtL1NU3afFk9ILAsEnXdy5lDDgKs="
    "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
  ];

  # common for deduplication
  inputs = {
    flake-compat.url = "github:edolstra/flake-compat";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    bird-nix-lib.url = "github:spikespaz/bird-nix-lib";
  };

  # hive / std
  inputs = {
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs-unstable";

    n2c.url = "github:nlewo/nix2container";
    n2c.inputs.nixpkgs.follows = "nixpkgs-unstable";
    n2c.inputs.flake-utils.follows = "flake-utils";

    makes.url = "github:fluidattacks/makes/24.01";
    makes.inputs.nixpkgs.follows = "nixpkgs-lib";

    paisano.url = "github:paisano-nix/core";
    paisano.inputs.nixpkgs.follows = "nixpkgs-unstable";
    paisano.inputs.yants.follows = "yants";

    incl.url = "github:divnix/incl";
    incl.inputs.nixlib.follows = "nixpkgs-lib";

    dmerge.url = "github:divnix/dmerge/0.2.1";
    dmerge.inputs.haumea.follows = "haumea";
    dmerge.inputs.yants.follows = "yants";
    dmerge.inputs.nixlib.follows = "nixpkgs-lib";

    haumea.url = "github:nix-community/haumea/v0.2.2";
    haumea.inputs.nixpkgs.follows = "nixpkgs-lib";

    yants.url = "github:divnix/yants";
    yants.inputs.nixpkgs.follows = "nixpkgs-lib";

    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs-unstable";
    colmena.inputs.flake-utils.follows = "flake-utils";

    nixago.url = "github:nix-community/nixago";
    nixago.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nixago.inputs.flake-utils.follows = "flake-utils";
    nixago.inputs.nixago-exts.follows = "nixago-exts";

    nixago-exts.url = "github:nix-community/nixago-extensions";
    nixago-exts.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nixago-exts.inputs.flake-utils.follows = "flake-utils";
    nixago-exts.inputs.nixago.follows = "nixago";

    terranix.url = "github:terranix/terranix/2.7.0";
    terranix.inputs.nixpkgs.follows = "nixpkgs-unstable";
    terranix.inputs.flake-utils.follows = "flake-utils";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs-unstable";

    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs-unstable";

    arion.url = "github:hercules-ci/arion";
    arion.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # std.follows = "hive/std";
    # std.url = "github:divnix/std/release/0.24";
    # commit used by hive: 0ce59ac671f041183da72e7cd5db9c6eb878e326

    std.url = "github:divnix/std/release/0.32";
    std.inputs.nixpkgs.follows = "nixpkgs-unstable";
    std.inputs.n2c.follows = "n2c";
    std.inputs.devshell.follows = "devshell";
    std.inputs.nixago.follows = "nixago";
    std.inputs.terranix.follows = "terranix";
    std.inputs.microvm.follows = "microvm";
    std.inputs.makes.follows = "makes";
    std.inputs.arion.follows = "arion";
    std.inputs.lib.follows = "nixpkgs-lib";
    std.inputs.paisano.follows = "paisano";
    std.inputs.dmerge.follows = "dmerge";
    std.inputs.haumea.follows = "haumea";
    std.inputs.incl.follows = "incl";

    hive.url = "github:divnix/hive";
    hive.inputs.std.follows = "std";
    hive.inputs.devshell.follows = "devshell";
    hive.inputs.paisano.follows = "paisano";
    hive.inputs.colmena.follows = "colmena";
    hive.inputs.nixago.follows = "nixago";
    hive.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  # tools
  inputs = {
    nix-filter.url = "github:numtide/nix-filter";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nixos-anywhere.url = "github:nix-community/nixos-anywhere/1.1.1";
    nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nixos-anywhere.inputs.disko.follows = "disko";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    impermanence.url = "github:nix-community/impermanence";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-unstable";
    sops-nix.inputs.nixpkgs-stable.follows = "nixos";

    sops-ssh-to-pgp.url = "github:Mic92/ssh-to-pgp/1.1.2";
    sops-ssh-to-pgp.inputs.nixpkgs.follows = "nixpkgs-unstable";

    sops-ssh-to-age.url = "github:Mic92/ssh-to-age/1.1.6";
    sops-ssh-to-age.inputs.nixpkgs.follows = "nixpkgs-unstable";

    devos-ext-lib.url = "github:divnix/devos-ext-lib/?ref=refs/pull/8/head";
    devos-ext-lib.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  # nixpkgs & home-manager
  inputs = {
    # latest.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs";
    nixos.url = "github:nixos/nixpkgs/release-23.11";
    latest.follows = "nixpkgs-unstable";
    nixpkgs.follows = "nixos";

    home.url = "github:nix-community/home-manager/release-23.11";
    home.inputs.nixpkgs.follows = "nixos";

    home-unstable.url = "github:nix-community/home-manager";
    home-unstable.inputs.nixpkgs.follows = "latest";

    home-activitywatch.url = "github:nix-community/home-manager?ref=pull/4429/head";
    home-activitywatch.inputs.nixpkgs.follows = "latest";

    srvos.url = "github:nix-community/srvos";
    srvos.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  # Compat nixpkgs
  inputs = {
    nixos-unstable-linux_6_2.url = "github:nixos/nixpkgs/63464b8c2837ec56e1d610f5bd2a9b8e1f532c07";
    nixos-unstable-linux_6_5.url = "github:nixos/nixpkgs/b644d97bda6dae837d577e28383c10aa51e5e2d2";
    nixos-22-11.url = "github:nixos/nixpkgs/release-22.11";
    nixpkgs-22-11.follows = "nixos-22-11"; # TODO: rework stumpwm-git!
    k8s.url = "github:nixos/nixpkgs/3005f20ce0aaa58169cdee57c8aa12e5f1b6e1b3";
  };

  # tools
  inputs = {
    nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
    nixos-vscode-server.inputs.nixpkgs.follows = "nixpkgs";
    nixos-vscode-server.inputs.flake-utils.follows = "flake-utils";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
    nix-vscode-extensions.inputs.flake-utils.follows = "flake-utils";

    nvfetcher.url = "github:berberman/nvfetcher";
    nvfetcher.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nvfetcher.inputs.flake-utils.follows = "flake-utils";

    nur.url = "github:nix-community/NUR";

    nurl.url = "github:nix-community/nurl";

    # go tools
    gomod2nix.url = "github:nix-community/gomod2nix";
    gomod2nix.inputs.nixpkgs.follows = "nixpkgs-master";
    gomod2nix.inputs.flake-utils.follows = "flake-utils";

    # Just in case
    call-flake.url = "github:divnix/call-flake";

    # terraform
    terraform-providers-bin.url = "github:nix-community/nixpkgs-terraform-providers-bin";
    terraform-providers-bin.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  # emacs & friends
  inputs = {
    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";

    # NOTE: https://github.com/nix-community/nix-straight.el/pull/4
    nix-doom-emacs.inputs.nix-straight.follows = "nix-straight-fix-emacs29";
    # nix-doom-emacs.inputs.emacs-overlay.follows = "emacs-overlay";

    nix-straight-fix-emacs29.url = "github:nix-community/nix-straight.el?ref=pull/4/head";
    nix-straight-fix-emacs29.flake = false;

    # emacs-overlay.url = "github:nix-community/emacs-overlay";
    # emacs-overlay.inputs.nixpkgs.follows = "nixos";

    # emacs-overlay.follows = "nix-doom-emacs/inputs/emacs-overlay";
    # emacs-overlay.url = "github:nix-community/emacs-overlay/c16be6de78ea878aedd0292aa5d4a1ee0a5da501";

    # LSP for nix
    nixd.url = "github:nix-community/nixd";
    nixd.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs =
    { self
    , std
    , nixpkgs
    , latest
    , hive
    , ...
    } @ inputs:
    std.growOn
      {
        inherit inputs;

        nixpkgsConfig.allowUnfree = true;

        systems = [ "aarch64-linux" "x86_64-linux" ];

        cellsFrom = ./cells;

        cellBlocks = with std.blockTypes;
          with hive.blockTypes; [
            (nixago "config")

            # Modules
            (functions "nixosModules")
            (functions "homeModules")

            # Profiles
            (functions "commonProfiles")
            (functions "nixosProfiles")
            (functions "homeProfiles")
            (functions "userProfiles")
            (functions "users")

            # Suites
            (functions "nixosSuites")
            (functions "homeSuites")

            (devshells "shells")
            (microvms "microvms")

            (functions "lib")

            (files "files")
            (installables "packages")
            (installables "firmwares")
            (pkgs "overrides")
            (functions "overlays")

            colmenaConfigurations
            homeConfigurations
            nixosConfigurations
            diskoConfigurations
          ];
      }

      # soil
      {
        devShells = hive.harvest inputs.self [ "repo" "shells" ];

        packages = hive.harvest inputs.self [
          [ "common" "packages" ]
        ];

        nixosModules = hive.pick inputs.self [
          [ "k8s" "nixosModules" ]
          [ "nixos" "nixosModules" ]
        ];

        homeModules = hive.pick inputs.self [ [ "home" "homeModules" ] ];
      }
      {
        colmenaHive = hive.collect self "colmenaConfigurations";
        nixosConfigurations = hive.collect self "nixosConfigurations";
        diskoConfigurations = hive.collect self "diskoConfigurations";
        homeConfigurations = hive.collect self "homeConfigurations";
      }
      {
        debug = hive.harvest inputs.self [ "repo" "debug" ];
      };
}
