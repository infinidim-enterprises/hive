{ inputs, cell, ... }:

{ pkgs, ... }:

{
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  # USB RTL8153 Gigabit Ethernet Adapter
  # ethtool -s enp3s0f3u3u1 speed 1000 duplex full autoneg off

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", ENV{ID_VENDOR_ID}=="0bda", ENV{ID_MODEL_ID}=="8153", RUN+="${pkgs.ethtool}/bin/ethtool -s $name speed 1000 duplex full autoneg off"
  '';
}
