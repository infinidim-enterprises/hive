{ config, lib, pkgs, modulesPath, ... }:

let
  inherit (lib) mkMerge mkIf mkOption mkEnableOption types;
  # moddedUserModule =
  #   with lib;
  #   pkgs.runCommandNoCC "patched_users-groups.nix"
  #     {
  #       buildInputs = with pkgs; [ gnused nixpkgs-fmt ];
  #     } ''
  #     # remove first and last lines
  #     sed '1d; $d' ${./_extraUserOpts.nix} > extraUserOpts.nix

  #     # patch the userOpts
  #     sed '/userOpts/,/options = {/!b;/options = {/r extraUserOpts.nix' \
  #     ${modulesPath}/config/users-groups.nix | nixpkgs-fmt > $out
  #   '';

  cfgDeploy = config.deploy;
  lanOptions = {
    options = with types; {
      enable = mkEnableOption "Have 'lan' interface";
      mac = mkOption { type = nullOr str; default = null; };
      ipv4 = mkOption { type = nullOr str; default = null; };
      ipxe = mkEnableOption "use ipxe" // { default = false; };
      dhcpClient = mkEnableOption "use dhcp" // { default = false; };
      dnsForwarder = mkEnableOption "forward DNS to local adguardhome" // { default = false; };
      server = mkOption { type = attrs; default = { }; };
    };
  };

in
{
  options.deploy = with types; {
    enable = mkEnableOption "Enable deploy config"; # // { default = true; };
    publicHost.enable = mkEnableOption "Public cloud hosted machine";
    extraUserOpts.enable = mkEnableOption "Patched users-groups.nix" // { default = true; };
    params = {
      cpu = mkOption { type = nullOr (enum [ "intel" "amd" ]); default = null; };
      gpu = mkOption { type = nullOr (enum [ "intel" "amd" "nvidia" ]); default = null; };
      ram = mkOption { type = nullOr int; description = "in GB"; default = null; };
      zfsCacheMax = mkOption {
        type = nullOr int;
        apply = v:
          if v != null
          then toString (v * 1024 * 1024 * 1024)
          else null;
        default = with cfgDeploy.params;
          if ram != null
          then ram / 8
          else null;
      };
      hidpi.enable = mkEnableOption "hiDpi";
      lan = mkOption { type = submodule [ lanOptions ]; default = { enable = false; }; };
    };
  };

  # disabledModules = [ "${modulesPath}/config/users-groups.nix" ];
  # imports = [ moddedUserModule ];
  config = mkMerge [
    # (mkIf (cfgDeploy.enable) { })
    # (mkIf cfgDeploy.extraUserOpts.enable {
    #   disabledModules = [ "${modulesPath}/config/users-groups.nix" ];
    #   imports = [ moddedUserModule ];
    # })
  ];
}
