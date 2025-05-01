{ config, lib, pkgs, ... }:
let
  inherit (lib // builtins)
    mkIf
    mkMerge
    mkOption
    mkEnableOption
    mkPackageOption
    literalExpression;

  cfg = config.programs.ghostty;
  ini = pkgs.formats.keyValue { };

in
{
  options.programs.ghostty = {
    enable = mkEnableOption "Enable ghostty";
    package = mkPackageOption pkgs "ghostty" { };
    settings = mkOption {
      type = ini.type;
      default = { };
      example = literalExpression ''{ keybind = "ctrl+d=new_split:right" }'';
      description = ''
        Settings for ghostty.
      '';
    };

  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [ cfg.package ];
      xdg.configFile."ghostty/config".source = ini.generate "ghostty_config" cfg.settings;
    }
  ]);
}
