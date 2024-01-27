{ inputs, cell, ... }:

{ config, lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  networking = {
    wireless.enable = mkDefault false;
    networkmanager.enable = false;
    enableIPv6 = false;
    firewall.allowPing = true;
    firewall.enable = true;
  };

  documentation.enable = false;
  documentation.man.enable = false;
  documentation.doc.enable = false;
  documentation.dev.enable = false;
  documentation.info.enable = false;
  documentation.nixos.enable = false;

  services.journald.extraConfig = "Storage=volatile";
  services.xserver.videoDrivers = mkDefault [ "intel" ];

  services.xserver.remote-display.client.enable = mkDefault true;
  services.xserver.remote-display.client.dbg.enable = mkDefault false;
  services.xserver.remote-display.client.brightness = mkDefault 10;
  services.xserver.remote-display.client.dbg.port = mkDefault 22220;

  zramSwap.enable = mkDefault true;
  zramSwap.memoryPercent = mkDefault 5;
  zramSwap.algorithm = mkDefault "zstd";
}
