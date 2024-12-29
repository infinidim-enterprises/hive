# { inputs, cell, ... }:

{ config, lib, pkgs, inputs, ... }:
let
  inherit (lib // builtins)
    mkIf
    mkMerge
    genAttrs
    mkOption
    mkEnableOption
    mkPackageOption
    literalExpression;

  cfg = config.programs.waveterm;
  json = pkgs.formats.json { };
in
{
  imports = [ ];

  options.programs.waveterm = with lib.types; {
    enable = mkEnableOption "Enable waveterm";
    package = mkPackageOption pkgs "waveterm" { };

    settings = mkOption {
      type = json.type;
      default = { };
      apply = attrs: attrs // { "autoupdate:enabled" = false; };
      example = literalExpression ''{ "telemetry:enabled" = false; }'';
      description = ''
        Settings for waveterm.
      '';
    };

    termthemes = mkOption {
      type = json.type;
      default = { };
      example = literalExpression ''{ "background" = "#002b36"; }'';
      description = ''
        Terminal themes for waveterm.
      '';
    };

    presets = mkOption {
      type = json.type;
      default = { };
      example = literalExpression ''{ "background" = "#002b36"; }'';
      description = ''
        Themes presets for waveterm tabs.
      '';
    };

    connections = mkOption {
      type = json.type;
      default = { };
      apply = attrs: attrs // genAttrs
        [ "git@github.com" "git@bitbucket.org" ]
        (_: { "display:hidden" = true; });
      example = literalExpression ''{ "user@host" = {}; }'';
      description = ''
        Connections overrides for waveterm.
      '';
    };

  };

  config = mkMerge [
    (mkIf cfg.enable {
      xdg.configFile."waveterm/settings.json".source = json.generate "settings.json" cfg.settings;
    })

    (mkIf (cfg.enable && cfg.termthemes != { }) {
      xdg.configFile."waveterm/termthemes.json".source = json.generate "termthemes.json" cfg.termthemes;
    })

    (mkIf (cfg.enable && cfg.presets != { }) {
      xdg.configFile."waveterm/presets.json".source = json.generate "presets.json" cfg.presets;
    })

    (mkIf (cfg.enable && cfg.presets != { }) {
      xdg.configFile."waveterm/connections.json".source = json.generate "connections.json" cfg.connections;
    })
  ];
}
