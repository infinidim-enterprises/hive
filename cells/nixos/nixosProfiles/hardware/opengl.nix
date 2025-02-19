{ inputs, cell, ... }:

{ pkgs, ... }:
{
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    intel-vaapi-driver
    intel-ocl
    mesa.drivers
  ];

  # hardware.opengl.driSupport = true;
  # hardware.opengl.driSupport32Bit = true;
  # hardware.opengl.extraPackages = with pkgs; [
  #   # vaapiIntel
  #   # vaapiVdpau
  #   # libvdpau-va-gl
  #   intel-media-driver
  # ];
}
