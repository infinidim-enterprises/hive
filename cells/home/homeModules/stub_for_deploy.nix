/*
  NOTE: deploy-rs cannot find home-manager.sharedModules definitions from nixosConfig
  This happens when it tries to eval homeConfigurations on it's own, hence stuff defined in host config doesn't get propagated
  Ultimately, I should collect all home-manager.sharedModules definitions automagically here.
*/
{ config, lib, ... }:
with lib;
{
  # options.services.opensnitch.enable = mkEnableOption "Enable nixos opensnitch module integration.";
  # options.services.opensnitch.allow = with types; mkOption {
  #   type = listOf anything;
  #   default = [ ];
  # };
}
