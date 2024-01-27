{ config, lib, pkgs, modulesPath, ... }:

let
  inherit (lib) mkMerge mkIf mkOption mkEnableOption types;
  moddedUserModule =
    with lib;
    let
      original = fileContents "${modulesPath}/config/users-groups.nix";
      extraUserOpts = fileContents ./_extraUserOpts.nix;
      patched = pkgs.runCommandNoCC "patch_users-groups.nix"
        {
          buildInputs = with pkgs; [ gnused ];
        } ''
        # remove first and last lines
        sed '1d; $d' input.txt > output.txt

        '/userOpts/,/options = {/ s/options = {/&\nname1 = mkOption {};/'
      '';
    in
    "";
  cfgDeploy = config.deploy;
  lanOptions = {
    options = with types; {
      mac = mkOption { type = nullOr str; default = null; };
      ipv4 = mkOption { type = nullOr str; default = null; };
      ipxe = mkEnableOption "use ipxe";
      dhcpClient = mkEnableOption "use dhcp" // { default = true; };
      server = mkOption { type = attrs; };
    };
  };

in
{
  options.deploy = with types; {
    enable = mkEnableOption "Enable deploy config"; # // { default = true; };
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
      lan = mkOption { type = submodule [ lanOptions ]; default = { }; };
    };
  };
  # config = mkMerge [ (mkIf (cfgDeploy.enable) { }) ];
}
