{
  description = "The Hive - VoD systems";

  # common for deduplication
  inputs = {
    flake-compat.url = "github:edolstra/flake-compat";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
  };

  # hive
  inputs = {
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    nixago.url = "github:nix-community/nixago";
    nixago.inputs.nixpkgs.follows = "nixpkgs";
    nixago.inputs.flake-utils.follows = "flake-utils";

    std.follows = "hive/std";

    # Compatibility
    std-ext.url = "github:gtrunsec/std-ext";
    nixos-22-11.url = "github:nixos/nixpkgs/release-22.11";
    # Compatibility

    hive.url = "github:divnix/hive";
    hive.inputs.colmena.follows = "colmena";
    hive.inputs.nixago.follows = "nixago";
    hive.inputs.nixpkgs.follows = "nixpkgs";

    haumea.follows = "hive/std/haumea";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "latest";
  };

  # tools
  inputs = {
    nix-filter.url = "github:numtide/nix-filter";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    nixos-wsl.inputs.flake-utils.follows = "flake-utils";

    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs";
    colmena.inputs.flake-utils.follows = "flake-utils";

    sops-nix.url = "github:TrueLecter/sops-nix/darwin-upstream";
    sops-nix.inputs.nixpkgs.follows = "nixos";
    sops-nix.inputs.nixpkgs-stable.follows = "nixos";

    sops-ssh-to-pgp.url = "github:Mic92/ssh-to-pgp/1.1.2";
    sops-ssh-to-pgp.inputs.nixpkgs.follows = "latest";

    sops-ssh-to-age.url = "github:Mic92/ssh-to-age/1.1.6";
    sops-ssh-to-age.inputs.nixpkgs.follows = "latest";
  };

  # nixpkgs & home-manager
  inputs = {
    latest.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs";
    k8s.url = "github:nixos/nixpkgs/3005f20ce0aaa58169cdee57c8aa12e5f1b6e1b3";
    nixos.url = "github:nixos/nixpkgs/release-23.05";
    nixpkgs.follows = "nixos";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixos";

    home.url = "github:nix-community/home-manager/release-23.05";
    home.inputs.nixpkgs.follows = "nixos";

    home-unstable.url = "github:nix-community/home-manager";
    home-unstable.inputs.nixpkgs.follows = "latest";

    srvos.url = "github:nix-community/srvos";
    srvos.inputs.nixpkgs.follows = "latest";
    srvos.inputs.nixos-23_05.follows = "nixos";
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
    nvfetcher.inputs.nixpkgs.follows = "nixpkgs";
    nvfetcher.inputs.flake-utils.follows = "flake-utils";

    microvm.url = "github:astro/microvm.nix";
    arion.url = "github:hercules-ci/arion";
    arion.inputs.nixpkgs.follows = "latest";

    nur.url = "github:nix-community/NUR";
    nurl.url = "github:nix-community/nurl";
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
    nil.url = "github:oxalica/nil";
    nixd.url = "github:nix-community/nixd";
  };

  outputs = {
    self,
    std,
    nixpkgs,
    latest,
    hive,
    ...
  } @ inputs:
    std.growOn
    {
      inherit inputs;

      nixpkgsConfig.allowUnfree = true;

      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      cellsFrom = ./cells;

      cellBlocks = with std.blockTypes;
      with hive.blockTypes; [
        (nixago "config")

        # Modules
        (functions "nixosModules")
        (functions "darwinModules")
        (functions "homeModules")

        # Profiles
        (functions "commonProfiles")
        (functions "nixosProfiles")
        (functions "darwinProfiles")
        (functions "homeProfiles")
        (functions "userProfiles")
        (functions "users")

        # Suites
        (functions "nixosSuites")
        (functions "darwinSuites")
        (functions "homeSuites")

        (devshells "shells")

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
        darwinConfigurations
      ];
    }
    # soil
    {
      devShells = hive.harvest inputs.self ["repo" "shells"];
      packages = hive.harvest inputs.self [
        ["klipper" "packages"]
        ["common" "packages"]
        ["pam-reattach" "packages"]
        ["minecraft-servers" "packages"]
      ];

      nixosModules = hive.pick inputs.self [
        ["klipper" "nixosModules"]
        ["k8s" "nixosModules"]
        ["minecraft-servers" "nixosModules"]
      ];

      homeModules = hive.pick inputs.self [["home" "homeModules"]];
    }
    {
      colmenaHive = hive.collect self "colmenaConfigurations";
      nixosConfigurations = hive.collect self "nixosConfigurations";
      diskoConfigurations = hive.collect self "diskoConfigurations";
      homeConfigurations = hive.collect self "homeConfigurations";
      darwinConfigurations = hive.collect self "darwinConfigurations";
    }
    {
      darwinConfigurations.squadbook = self.darwinConfigurations.darwin-squadbook;
      debug = hive.harvest inputs.self ["repo" "debug"];
    };
}
