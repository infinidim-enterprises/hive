{ inputs, cell, ... }:

{ lib, ... }:
{ services.xserver.windowManager.stumpwm.enable = lib.mkDefault true; }
