{ inputs, cell, ... }:

{ lib, config, ... }:
{
  security.rtkit.enable = lib.mkDefault config.services.pipewire.enable;
  # NOTE[ref]: https://github.com/yunfachi/nix-config/blob/master/modules/services/pipewire.nix

  services.pipewire.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.wireplumber.enable = true;
  services.pipewire.alsa.support32Bit = true;
  services.pipewire.pulse.enable = true;
}
