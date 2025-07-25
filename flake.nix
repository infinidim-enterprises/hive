{
  description = "The Hive - VoD systems";
  # Cachix
  nixConfig.extra-substituters = [
    "https://njk.cachix.org"
    "https://cache.garnix.io"
    "https://nix-community.cachix.org"
  ];

  nixConfig.extra-trusted-public-keys = [
    "njk.cachix.org-1:ON4lemYq096ZfK5MtL1NU3afFk9ILAsEnXdy5lDDgKs="
    "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  # nixConfig.download-buffer-size = builtins.toString (10 * 1024 * 1024);

  inputs = {
    # common for deduplication
    flake-compat.url = "github:edolstra/flake-compat";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    # TODO: bird-nix-lib.url = "github:spikespaz/bird-nix-lib";
    # TODO: flake-schemas.url = "github:DeterminateSystems/flake-schemas";

    ###
    # hive / std
    ###
    devshell.url = "github:numtide/devshell";
    # devshell.inputs.nixpkgs.follows = "nixpkgs-unstable";

    n2c.url = "github:nlewo/nix2container";
    n2c.inputs.nixpkgs.follows = "nixpkgs-unstable";
    # n2c.inputs.flake-utils.follows = "flake-utils";

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
    # colmena.inputs.nixpkgs.follows = "nixpkgs-unstable";
    # colmena.inputs.flake-utils.follows = "flake-utils";

    nixago.url = "github:nix-community/nixago";
    # nixago.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nixago.inputs.flake-utils.follows = "flake-utils";
    nixago.inputs.nixago-exts.follows = "nixago-exts";

    nixago-exts.url = "github:nix-community/nixago-extensions";
    # nixago-exts.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nixago-exts.inputs.flake-utils.follows = "flake-utils";
    nixago-exts.inputs.nixago.follows = "nixago";

    terranix.url = "github:terranix/terranix/2.8.0";
    terranix.inputs.nixpkgs.follows = "nixpkgs-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs-unstable";

    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs-unstable";

    arion.url = "github:hercules-ci/arion";
    arion.inputs.nixpkgs.follows = "nixpkgs-unstable";

    std.url = "github:divnix/std/v0.33.4";
    # std.inputs.nixpkgs.follows = "nixpkgs-unstable";
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
    # hive.inputs.nixpkgs.follows = "nixpkgs-unstable";

    ###
    # system tools
    ###
    # TODO: inputs.nix-topology.url = "github:oddlama/nix-topology";
    # TODO: nix-super.url = "github:privatevoid-net/nix-super";

    nix-filter.url = "github:numtide/nix-filter";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nixos-generators.inputs.nixlib.follows = "nixpkgs-lib";

    nixos-anywhere.url = "github:nix-community/nixos-anywhere/1.8.0";
    nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nixos-anywhere.inputs.disko.follows = "disko";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    impermanence.url = "github:nix-community/impermanence";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-unstable";
    # sops-nix.inputs.nixpkgs-stable.follows = "nixos";

    # NOTE: ssh root@host "cat /etc/ssh/ssh_host_rsa_key" | ssh-to-pgp -o nixos/secrets/keys/host.asc
    sops-ssh-to-pgp.url = "github:Mic92/ssh-to-pgp/1.1.6";
    sops-ssh-to-pgp.inputs.nixpkgs.follows = "nixpkgs-unstable";

    sops-ssh-to-age.url = "github:Mic92/ssh-to-age/1.1.11";
    sops-ssh-to-age.inputs.nixpkgs.follows = "nixpkgs-unstable";

    devos-ext-lib.url = "github:divnix/devos-ext-lib/?ref=refs/pull/8/head";
    devos-ext-lib.inputs.nixpkgs.follows = "nixpkgs-unstable";

    ###
    # nixpkgs & home-manager
    ###
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs";

    # nixos.follows = "nixos-24-11";
    # nixpkgs.follows = "nixos-24-11";
    nixos.follows = "nixos-25-05";
    nixpkgs.follows = "nixos-25-05";
    nixpkgs-release.follows = "nixos-25-05";
    latest.follows = "nixpkgs-unstable";

    home.url = "github:nix-community/home-manager/release-25.05";
    home.inputs.nixpkgs.follows = "nixos";

    home-unstable.url = "github:nix-community/home-manager";
    home-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # srvos.url = "github:nix-community/srvos";
    # srvos.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Nix flake for "too much bleeding-edge" and unreleased packages
    # nyx.url = "github:chaotic-cx/nyx";

    ###
    # Compat nixpkgs
    ###
    # nixos-22-11.url = "github:nixos/nixpkgs/release-22.11";
    # nixos-23-11.url = "github:nixos/nixpkgs/release-23.11";
    # nixos-24-05.url = "github:nixos/nixpkgs/release-24.05";
    nixos-24-11.url = "github:nixos/nixpkgs/release-24.11";
    nixos-25-05.url = "github:nixos/nixpkgs/release-25.05";
    # ISSUE: xdg.portal.enable is fucked on update (something to do with home-unstable)
    # nixos-24-11.url = "github:nixos/nixpkgs/785306ca6d78689fb32ab67843ac93ebd53be15e";

    ###
    # rpi stuff
    ###
    # "github:nix-community/raspberry-pi-nix";
    raspberry-pi-nix.url = "github:infinidim-enterprises/raspberry-pi-nix";
    raspberry-pi-nix.inputs.nixpkgs.follows = "nixos-24-11";

    ###
    # kubernetes and friends
    ###
    # k8s.url = "github:nixos/nixpkgs/3005f20ce0aaa58169cdee57c8aa12e5f1b6e1b3";

    kubenix.url = "github:hall/kubenix";
    kubenix.inputs.nixpkgs.follows = "nixpkgs-unstable";

    ###
    # tools
    ###
    # nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
    # nixos-vscode-server.inputs.nixpkgs.follows = "nixpkgs";
    # nixos-vscode-server.inputs.flake-utils.follows = "flake-utils";

    # flakey-devShells.url = "github:GetPsyched/not-so-flakey-devshells";
    # flakey-devShells.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    # nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
    # nix-vscode-extensions.inputs.flake-utils.follows = "flake-utils";

    # TODO: move to stylix!
    # stylix.url = "github:danth/stylix";
    # stylix.inputs.nixpkgs.follows = "nixpkgs-unstable";
    # stylix.inputs.home-manager.follows = "home-unstable";

    # TODO: hyprspace VPN
    # hyprspace.url = "github:hyprspace/hyprspace";
    # hyprspace.inputs.flake-parts.follows = "flake-parts";
    # hyprspace.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: fork and PR a fix for https://github.com/danth/stylix/blob/73c6955b4572346cc10f43a459949fe646efbde0/modules/nixvim/nixvim.nix#L16
    # nixvim.url = "github:nix-community/nixvim";
    # nixvim.url = "github:nix-community/nixvim";
    # nixvim.inputs.nixpkgs.follows = "nixpkgs-unstable";
    # nixvim.inputs.home-manager.follows = "home-unstable";

    /*radicle = {
      url = "git+https://seed.radicle.xyz/z3gqcJUoA1n9HaHKufZs5FCSGazv5.git";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      };*/

    # TODO: netboot-nix.url = "github:grahamc/netboot.nix";

    nvfetcher.url = "github:berberman/nvfetcher/0.7.0";

    # go tools
    # gomod2nix.url = "github:nix-community/gomod2nix";
    # gomod2nix.inputs.nixpkgs.follows = "nixpkgs-master";
    # gomod2nix.inputs.flake-utils.follows = "flake-utils";

    # Just in case
    call-flake.url = "github:divnix/call-flake";

    # terraform
    terraform-providers-bin.url = "github:nix-community/nixpkgs-terraform-providers-bin";
    terraform-providers-bin.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # AAA
    # TODO: authentik
    # authentik-nix.url = "github:nix-community/authentik-nix";

    ###
    # emacs & friends
    ###
    nix-doom-emacs-unstraightened.url = "github:marienz/nix-doom-emacs-unstraightened";
    nix-doom-emacs-unstraightened.inputs.nixpkgs.follows = "nixpkgs-release";

    # LSP for nix
    nixd.url = "github:nix-community/nixd?ref=refs/tags/2.6.4";
    # TODO: https://github.com/nix-community/nixd/blob/main/nixd/docs/user-guide.md
    # flake-compat, so options are visible
    # nixd.inputs.nixpkgs.follows = "nixpkgs-unstable";

    metagpt.url = "github:infinidim-enterprises/metagpt.nix";
  };

  outputs =
    { self
    , std
    , hive
    , ...
    }@inputs:
    std.growOn
      {
        inherit inputs;
        systems = [ "aarch64-linux" "x86_64-linux" ];
        nixpkgsConfig.allowUnfree = true;
        cellsFrom = ./cells;

        cellBlocks =
          with std.blockTypes;
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
            (functions "arionProfiles")

            # Suites
            (functions "nixosSuites")
            (functions "homeSuites")

            (devshells "shells" { ci.build = true; })

            (microvms "microvms")
            (arion "arionConfigurations")
            (containers "containers" { ci.publish = true; })
            # TODO: (terra "infra" "git@github.com:myorg/myrepo.git")

            (functions "lib")

            (files "files")
            (installables "packages" { ci.build = true; })
            (installables "firmwares")
            (pkgs "overrides")
            (functions "overlays")

            colmenaConfigurations
            homeConfigurations
            nixosConfigurations
            diskoConfigurations
          ];
      }

      {
        devShells = hive.harvest inputs.self [ "repo" "shells" ];

        packages = hive.harvest inputs.self [
          [ "common" "packages" ]
          [ "containers" "packages" ]
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
