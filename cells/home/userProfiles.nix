{ inputs, cell, ... }:
let
  inherit (builtins) baseNameOf;
  extraGroups = [
    "wireshark"
    "nitrokey"
    "backup"
    "gnunet"
    "networkmanager"
    "disk"
    "lp"
    "audio"
    "pulse"
    "sound"
    "video"
    "media"
    "input"
    "kvm"
    "plugdev"
    "network"
    "systemd-journal"
    "adbusers"
    "xrdp"
    "dialout"
  ];
in

{
  inherit extraGroups;

  root.users.users."root" = {
    hashedPassword = "$6$KSKezdF73TXL$IM6t1ohC4b81iMo0cQyaFv9YBN7c8w0ASBgDkBjlVkKuf/oIvGSKecwlklkUCgFJVTVNhxofr0kRX0jJHvV0w.";
    inherit (cell.secretProfiles.vod) openssh;
  };
} // inputs.cells.common.lib.importers.importProfilesRakeleaves {
  src = ./userProfiles;
  inputs = { inherit cell inputs; };
}
