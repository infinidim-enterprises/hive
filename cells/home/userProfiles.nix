{ inputs, cell, ... }:
let
  lib = inputs.nixpkgs-lib.lib // builtins;
  extraGroups = [
    "backup"
    "disk"
    "lp"

    "audio"
    "sound"
    "video"
    "plugdev"

    "media"
    "input"

    "network"
    "systemd-journal"

    "dialout"
  ];
in

{
  extraGroupsMod = user:
    { config, ... }:
      with lib;
      mkMerge [
        (mkIf config.virtualisation.libvirtd.enable
          {
            home-manager.users.${user}.imports = [
              cell.homeProfiles.virtualisation.libvirtd
            ];
          })
        {
          users.users.${user}.extraGroups = (attrNames
            (filterAttrs
              (n: v: elem n extraGroups)
              config.users.groups)) ++
          optional config.virtualisation.docker.enable "docker" ++
          optional config.virtualisation.podman.enable "podman" ++
          optional config.virtualisation.libvirtd.enable "libvirtd" ++
          optional config.programs.wireshark.enable "wireshark" ++
          optional config.hardware.nitrokey.enable "nitrokey" ++
          optional config.networking.networkmanager.enable "networkmanager" ++
          optional config.hardware.pulseaudio.enable "pulse-access" ++
          optional config.programs.adb.enable "adbusers" ++
          optional config.services.trezord.enable "trezord";
        }
      ];

  root = { config, ... }: {
    users.users.root = {
      homeMode = "0700";
      createHome = true;
      home = "/root";
      # hashedPasswordFile = config.sops.secrets.root-password.path;
      # inherit (config.users.users.vod) openssh;
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCwIsdZ2Wz2u1hyQpzDqSwk2x8kmh4Uo0w47eTVQLpIWn+zur9BjlwCWSy5xnRlnu5C8BqBhDF1dl5MeXKakIFiXRPNPtHMfeTe+Q9B0Q1cM5/ZiHM9Du9rdZ6nZRlkjB1t8ShqxVrMRKn6Ed+3yX3DJ/Ab8szxgoO4IDrnJDs4cUvGv7n4XrkESrHddeQfOuik0rZiLu1iw12cyuLQmJWpq8Q5BMHEBeGWvj68D5wHeHLhfK+ZacU8IezqUmPp+ECZLR9vhf3Kel1QZb1s9F2+RUWgbo+KPJSNxSmHJ25kji32M1eVd6cA9BoPqRFzHWISXL7CM52z5Z+E+hyeVmR2jIx9agS9iTLczTO7Hs4lEoFESPmT/FkB0YefIzy17j+8bKItCeZDfmy5M056I/kShZIPp86fM5dmH/PSKngyozKz6MrbBxJkhAlsXmhbGqmHALcy19vEYF/4mbb4gf6gLWUwsho10UvkMybQ2jpsdvGkqJg89hMqFbYKBPN9lAnRoPVlKS7SBBfnLjC9RtHduwvoYHJeXQNaGW1mNCbg1M/WmqghY4BWKTqxCPoraejtFVLjB9DepRAmQg+fZrQYq+Q+A1yHFVTwrxapIseD9Udth+kAsUKbYP3vUsFDlSdFz3U6QWH8TnhwCsRbIvOYptPmc0o3kNQ4buC/vZCP1w== openpgp:0x1F41C323" ];
    };

  };
} // inputs.cells.common.lib.importers.importProfilesRakeleaves {
  src = ./userProfiles;
  inputs = { inherit cell inputs; };
}
