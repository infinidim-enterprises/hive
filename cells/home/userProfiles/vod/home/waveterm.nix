{ inputs, config, lib, pkgs, ... }:

{
  programs.waveterm.enable = true;
  programs.waveterm.settings = {
    "autoupdate:enabled" = false;
    "telemetry:enabled" = false;
    "term:copyonselect" = true;
  };
}
