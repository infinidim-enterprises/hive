{
  inputs,
  cell,
  ...
}: let
  inherit (inputs) haumea;
  inherit (inputs.nixpkgs-lib) lib;
  inherit (builtins) attrValues mapAttrs removeAttrs isPath;

  defaultNixpkgs = import inputs.nixpkgs {inherit (inputs.nixpkgs) system;};
  defaultAsRoot = _: mod: mod.default or mod;

  importLibs = {src ? ./lib}:
    haumea.lib.load {
      inherit src;
      inputs = {
        inputs = removeAttrs inputs ["self"];
        inherit lib;
      };
      transformer = haumea.lib.transformers.liftDefault;
    };
in
  rec
  {
    inherit importLibs;

    importProfiles = {
      inputs ? {},
      src,
      ...
    }:
      haumea.lib.load {
        inherit src inputs;
        transformer = haumea.lib.transformers.liftDefault;
      };

    importModules = {src}:
      haumea.lib.load {
        inherit src;
        loader = haumea.lib.loaders.path;
      };

    combineModules = {src}: _: {
      imports = attrValues (importModules {inherit src;});
    };

    # TODO: pass nixpkgs as well,  implicit bee module
    importSystemConfigurations = {
      src,
      skip ? [],
      suites,
      profiles,
      userProfiles,
      lib,
      inputs,
      overlays ? {},
      ...
    }: let
      filtered = with builtins;
        if skip != []
        then filterSource (path: _: (match ".*(${concatStringsSep "|" skip})" (toString path)) == null) src
        else src;
    in
      haumea.lib.load {
        src = filtered;
        transformer = defaultAsRoot;
        inputs = {inherit suites profiles userProfiles lib inputs overlays;};
      };

    importPackages = {
      nixpkgs ? defaultNixpkgs,
      sources ? null,
      extraArguments ? {},
      packages,
      ...
    }: let
      sources' =
        if isPath sources
        then (nixpkgs.callPackage sources {})
        else sources;
      pkgs =
        mapAttrs
        (_: v: nixpkgs.callPackage v (extraArguments // {sources = sources';}))
        (haumea.lib.load {
          src = packages;
          loader = haumea.lib.loaders.path;
        });
    in
      pkgs // {sources = sources';};
  }
  // (importLibs {})
