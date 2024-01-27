{ inputs, cell, ... }:
let
  inherit (inputs.nixpkgs-lib.lib // builtins) optionals hasAttrByPath filterAttrs;
  inherit (inputs.cells.common.lib) disableModulesFrom;
  # nixpkgs = inputs.nixpkgs.appendOverlays cell.overlays.desktop;

  isZfs = config:
    (filterAttrs (n: v: v.fsType == "zfs") config.fileSystems) != { };
in
{
  inherit isZfs;

  mkHome = username: host: shell: {
    imports =
      [
        cell.nixosModules.hm-system-defaults

        ({ pkgs, lib, config, ... }: {
          programs.${shell}.enable = true;
          users.users.${username}.shell = pkgs.${shell};

          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            # NOTE: compatibility layer for old, digga based config
            inherit inputs;
            inherit (inputs) self;
            suites = cell.homeSuites;
            profiles = cell.homeProfiles;
          };

          home-manager.users.${username} = { osConfig, ... }: {
            inherit (cell.lib.mkHomeConfig host username) imports;
            programs.${shell}.enable = osConfig.programs.${shell}.enable;
            home.stateVersion = osConfig.bee.pkgs.lib.trivial.release;
          };
        })
      ]
      ++ optionals (shell == "zsh") [{ programs.zsh.enableCompletion = true; }]
      ++ optionals (hasAttrByPath [ username ] cell.userProfiles) [ cell.userProfiles.${username} ];
  };

  mkHomeConfig = host: username: {
    bee = cell.nixosConfigurations.${host}.bee;
    home = {
      inherit username;
      homeDirectory = "/home/${username}";
      stateVersion = cell.nixosConfigurations.${host}.bee.pkgs.lib.trivial.release;
    };
    imports =
      let
        hostSpecific = optionals
          (hasAttrByPath
            [ "hostSpecific" host ]
            cell.homeSuites)
          cell.homeSuites.hostSpecific.${host};
        userSpecific = optionals
          (hasAttrByPath
            [ "userSpecific" username ]
            cell.homeSuites)
          cell.homeSuites.userSpecific.${username};
      in
      hostSpecific ++
      userSpecific ++
      cell.homeSuites.default ++
      [{ disabledModules = disableModulesFrom ./homeModules; }] ++
      (with cell.homeModules; [
        services.trezor-agent
        services.emacs
        programs.firefox
        programs.promnesia
        programs.chemacs
        programs.activitywatch
      ]) ++
      [
        # "${inputs.home-activitywatch}/modules/services/activitywatch.nix"
      ];
  };
}
