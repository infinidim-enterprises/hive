{ inputs, cell, ... }:

{ lib, ... }: { services.xserver.windowManager.stumpwm-new.enable = lib.mkDefault true; }
