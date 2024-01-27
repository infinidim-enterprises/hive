{ inputs, cell, ... }:

{ config, pkgs, lib, ... }:

# evtest, xev
# fnmode:Mode of fn key on Apple keyboards (0 = disabled , [1] = fkeyslast, 2 = fkeysfirst)
# fn+x+l switches it from mac/win and back or something, one of the modes don't work.

{
  # needs to be in MAC mode with this param and the fn keys work from the start!
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=0
  '';
}
