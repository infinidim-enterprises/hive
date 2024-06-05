{ inputs, cell, ... }:
let
  inherit (inputs.nixpkgs-lib.lib // builtins)
    mkForce
    optional
    mkDefault
    optionals
    filterAttrs
    removeAttrs
    hasAttrByPath;
  inherit (inputs.cells.common.lib) disableModulesFrom;

  isZfs = config:
    (filterAttrs (n: v: v.fsType == "zfs") config.fileSystems) != { };
  isGui = config:
    let
      dm = removeAttrs config.services.xserver.displayManager
        [
          "auto"
          "desktopManagerHandlesLidAndPower"
          "slim"
          "sddm"
          "autoLogin"
          "defaultSession"
          "extraSessionFilesPackages"
          "hiddenUsers"
          "logToJournal"
          "sessionData"
          "sessionPackages"
        ];
    in
    (filterAttrs (k: v: v ? enable && v.enable) dm) != { };
in
{
  inherit isZfs isGui;

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
            localLib = { inherit isGui; };
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
