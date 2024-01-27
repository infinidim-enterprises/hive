{ inputs, cell, ... }:

{ pkgs, ... }:
{
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages = with pkgs; [
    # vaapiIntel
    # vaapiVdpau
    # libvdpau-va-gl
    intel-media-driver
  ];
}
