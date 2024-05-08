{ inputs, cell, ... }:
let
  inherit (inputs.nixpkgs-lib.lib // builtins)
    mkForce
    optional
    mkDefault
    optionals
    filterAttrs
    hasAttrByPath;
  inherit (inputs.cells.common.lib) disableModulesFrom;
  # nixpkgs = inputs.nixpkgs.appendOverlays cell.overlays.desktop;

  isZfs = config:
    (filterAttrs (n: v: v.fsType == "zfs") config.fileSystems) != { };
in
{
  inherit isZfs;

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
                  services.trezor-agent
                  services.emacs
                  programs.firefox
                  programs.promnesia
                  programs.chemacs
                  programs.activitywatch
                ]); # TODO: add activitywatch from home-manager!
            };
        })
      ]
      ++ optional (hasAttrByPath [ username ] inputs.cells.home.userProfiles)
        inputs.cells.home.userProfiles.${username};
  };
}
