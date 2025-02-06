{ inputs, cell, ... }:
let
  inherit (inputs.nixpkgs-lib.lib // builtins)
    elem
    # mkForce
    # isAttrs
    hasAttr
    flatten
    optional
    isString
    # mkDefault
    findFirst
    hasSuffix
    # optionals
    filterAttrs
    # removeAttrs
    removeSuffix
    hasAttrByPath
    versionAtLeast
    mapAttrsToList;
  # inherit (inputs.cells.common.lib) disableModulesFrom;

  isImpermanence = config:
    (hasAttrByPath [ "persistence" ] config.environment) &&
    (config.environment.persistence != { });

  impermanenceMounts = config:
    map
      (e:
        if hasAttr "filePath" e
        then e.filePath
        else e.dirPath)
      (flatten (mapAttrsToList (_: v: v.files ++ v.directories)
        config.environment.persistence));
  isZfs = config:
    (filterAttrs (n: v: v.fsType == "zfs") config.fileSystems) != { };

  localLib = {
    post_24-05 = { pkgs }:
      let
        version =
          if hasSuffix "pre-git" pkgs.lib.version
          then removeSuffix "pre-git" pkgs.lib.version
          else pkgs.lib.version;
      in
      versionAtLeast version "24.11";

    networkdSyntax = { pkgs, Address }:
      if cell.lib.post_24-05 { inherit pkgs; }
      then { inherit Address; }
      else { addressConfig = { inherit Address; }; };

    pkgInstalled = { pkg, combinedPkgs }:
      elem pkg combinedPkgs;

    fontPkg = { name, osConfig }:
      findFirst (e: (!isString e) && hasAttr "pname" e && e.pname == name)
        null
        osConfig.fonts.packages;

    # NOTE: displayManager.enable will be true, when any DM is enabled
    isGui = config: config.services.displayManager.enable;
  };

in
{
  inherit (localLib)
    isGui
    post_24-05
    networkdSyntax;

  inherit
    isZfs
    isImpermanence
    impermanenceMounts;

  mkHome = username: shell: {
    imports =
      [
        cell.nixosProfiles.home-manager-defaults
        (inputs.cells.home.userProfiles.extraGroupsMod username)
        ({ pkgs, ... }: {
          programs.${shell} = {
            enable = true;
            vteIntegration = true;
            enableCompletion = true;
          };
          users.users.${username}.shell = pkgs.${shell};

          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            # TODO: lib.extend (_: _: { inherit isGui; }) # Do it for the lib, passed into home-manager
            inherit localLib;
            # NOTE: compatibility layer for old, digga based config
            # TODO: refactor and remove compatibility layer!
            inherit inputs;
            inherit (inputs) self;
            suites = inputs.cells.home.homeSuites;
            profiles =
              inputs.cells.home.homeProfiles //
              { inherit (inputs.cells.emacs.homeProfiles) emacs; };
          };

          home-manager.users.${username} = { osConfig, ... }:
            {
              programs.${shell}.enable = osConfig.programs.${shell}.enable;
              home.homeDirectory = osConfig.users.users.${username}.home;
              home.stateVersion = osConfig.bee.pkgs.lib.trivial.release;
              imports =
                inputs.cells.home.homeSuites.default ++
                (with inputs.cells.home.homeModules; [
                  services.emacs
                  programs.promnesia
                  programs.chemacs
                ]);
            };
        })
      ]
      ++ optional (hasAttrByPath [ username ] inputs.cells.home.userProfiles)
        inputs.cells.home.userProfiles.${username};
  };
}
