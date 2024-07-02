{ config, lib, pkgs, ... }:

{
  # FIXME: killall -SIGUSR2 waybar after kanshi runs!
  services.kanshi.enable = true;
}
