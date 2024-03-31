{
  description = "Rubygem - XXX";

  nixConfig = {
    extra-trusted-public-keys = [
      "njk.cachix.org-1:ON4lemYq096ZfK5MtL1NU3afFk9ILAsEnXdy5lDDgKs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
    extra-substituters = [ "https://njk.cachix.org" "https://cache.garnix.io" ];
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

    # disko.url = "github:nix-community/disko";
    # disko.inputs.nixpkgs.follows = "nixpkgs-unstable";

    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs-unstable";

    arion.url = "github:hercules-ci/arion";
    arion.inputs.nixpkgs.follows = "nixpkgs-unstable";

    std.url = "github:divnix/std/release/0.33";
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

  # system tools
  inputs = {
    nvfetcher.url = "github:berberman/nvfetcher/0.6.2";
    nix-filter.url = "github:numtide/nix-filter";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-unstable";
    sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs-release";

    flake-compat.url = "github:edolstra/flake-compat";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    bird-nix-lib.url = "github:spikespaz/bird-nix-lib";
  };

  # nixpkgs
  inputs = {
    nixpkgs.follows = "nixpkgs-release";
    nixpkgs-master.url = "github:nixos/nixpkgs";
    nixpkgs-release.url = "github:nixos/nixpkgs/release-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  # LSP for nix
  inputs = {
    nixd.url = "github:nix-community/nixd";
    nix4nixd.url = "github:NixOS/nix/2.19.4";
    nixd.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = { self, std, nixpkgs, hive, ... } @ inputs:
    std.growOn
      {
        inherit inputs;
        nixpkgsConfig.allowUnfree = true;
        systems = [ "aarch64-linux" "x86_64-linux" ];
        cellsFrom = ./nix;

        cellBlocks = with std.blockTypes;
          with hive.blockTypes; [
            (functions "lib")
            (nixago "config")
            (files "files")

            (devshells "shells" { ci.build = true; })
            (installables "packages" { ci.build = true; })

            (pkgs "overrides")
            (functions "overlays")

            (functions "homeModules")
            (functions "nixosModules")
            (functions "arionProfiles")

            (microvms "microvms")
            (arion "arionConfigurations")
            (containers "containers" { ci.publish = true; })
          ];
      }

      {
        devShells = hive.harvest inputs.self [ "repo" "shells" ];
        packages = hive.harvest inputs.self [
          [ "common" "packages" ]
          # [ "containers" "packages" ]
        ];

        nixosModules = hive.pick inputs.self [ [ "nixos" "nixosModules" ] ];
        homeModules = hive.pick inputs.self [ [ "home" "homeModules" ] ];
      };
}
