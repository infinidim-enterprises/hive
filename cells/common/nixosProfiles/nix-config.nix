{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
let
  GB = 1024 * 1024 * 1024;
  MB = 1024 * 1024;
  inherit (builtins) attrNames attrValues;
  cachix = {
    # NOTE: always set from the default module: "https://cache.nixos.org/" = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
    # "https://cuda-maintainers.cachix.org" = "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E=";
    "http://nix-community.cachix.org" = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    "https://poetry2nix.cachix.org" = "poetry2nix.cachix.org-1:2EWcWDlH12X9H76hfi5KlVtHgOtLa1Xeb7KjTjaV/R8=";
    # "https://ibis.cachix.org" = "ibis.cachix.org-1:tKNWCdKmBXJFK1JE/SnA41z7U7XPFOnB7Nw0vLKXaLA=";
    # "https://ibis-substrait.cachix.org" = "ibis-substrait.cachix.org-1:9QMhfByEHEl46s4tqVcRiyiOct2bnmZ23BJk4NTgGGI=";
    "https://njk.cachix.org" = "njk.cachix.org-1:ON4lemYq096ZfK5MtL1NU3afFk9ILAsEnXdy5lDDgKs=";
    "https://cache.garnix.io" = "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=";
    "https://nrdxp.cachix.org" = "nrdxp.cachix.org-1:Fc5PSqY2Jm1TrWfm88l6cvGWwz3s93c6IOifQWnhNW4=";
    "https://colmena.cachix.org" = "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg=";
    "https://microvm.cachix.org" = "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys=";
    "https://emacs.cachix.org" = "emacs.cachix.org-1:b1SMJNLY/mZF6GxQE+eDBeps7WnkT0Po55TAyzwOxTY=";
    "https://mic92.cachix.org" = "mic92.cachix.org-1:gi8IhgiT3CYZnJsaW7fxznzTkMUOn1RY4GmXdT/nXYQ=";
  };
in

{
  nix.package = pkgs.nixVersions.latest;
  nix.optimise.automatic = lib.mkDefault true;
  nix.nrBuildUsers = 0;
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 14d";
  nix.settings.nix-path = [ "nixpkgs=${pkgs.path}" ];
  nix.settings.allowed-users = [ "@wheel" ];
  nix.settings.trusted-users = [ "root" "@wheel" ];
  nix.settings.auto-optimise-store = lib.mkDefault true;
  nix.settings.substituters = attrNames cachix;
  # nix.settings.trusted-substituters = attrNames cachix;
  nix.settings.trusted-public-keys = attrValues cachix;
  nix.settings.sandbox = true;
  nix.settings.keep-outputs = lib.mkDefault true;
  nix.settings.keep-derivations = lib.mkDefault true;
  nix.settings.fallback = true;
  nix.settings.warn-dirty = false;
  nix.settings.min-free = lib.mkDefault (5 * GB);
  nix.settings.download-buffer-size = lib.mkDefault (10 * MB);
  nix.settings.builders-use-substitutes = true;
  nix.settings.auto-allocate-uids = true;
  nix.settings.use-cgroups = true;
  nix.settings.system-features = [
    "nixos-test"
    "benchmark"
    "big-parallel"
    "kvm"
    "recursive-nix"
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
    # https://github.com/NixOS/nix/issues/6666
    # https://github.com/NixOS/nixpkgs/issues/177142
    # BUG: "ca-derivations"
    "auto-allocate-uids"
    "cgroups"
    # "recursive-nix"
  ];
  nix.extraOptions = ''
    accept-flake-config = true
  '';

  nix.registry = {
    home.flake = inputs.home;
    nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
  };
  /*
    TODO: nixpkgs.flake.setNixPath nixpkgs.flake.setFlakeRegistry
  */
  nix.nixPath = [
    # TODO:     "nixos-config=${../lib/compat/nixos}"
    "nixpkgs=${pkgs.path}"
    "home-manager=flake:home"
  ];

}
