{ config, lib, pkgs, ... }:

{
  programs.wofi.enable = true;
  # programs.wofi.style = lib.fileContents ./wofi_solarized-dark.css;
  programs.wofi.settings = {
    insensitive = true;
    hide_scroll = true;
    key_exit = "Ctrl-g";
  };
}
