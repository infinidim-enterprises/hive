{ inputs, config, lib, pkgs, ... }:

{
  imports = [ inputs.cells.home.homeModules.programs.waveterm ];

  programs.waveterm.enable = true;
  programs.waveterm.settings = {
    "telemetry:enabled" = false;
    "term:copyonselect" = true;
    "conn:askbeforewshinstall" = false;
    "term:scrollback" = 10000;
    "web:defaultsearch" = "https://duckduckgo.com/?q={query}";
  };
}
