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
    "i2c"

    "samba"
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
          [ "plugdev" ] ++ # allow access to yubikey from ssh logins.
          optional config.virtualisation.docker.enable "docker" ++
          optional config.virtualisation.podman.enable "podman" ++
          optional config.virtualisation.libvirtd.enable "libvirtd" ++
          optional config.programs.wireshark.enable "wireshark" ++
          optional config.hardware.nitrokey.enable "nitrokey" ++
          optional config.networking.networkmanager.enable "networkmanager" ++
          optional (config.services.pulseaudio.enable or config.hardware.pulseaudio.enable) "pulse-access" ++
          optional config.programs.adb.enable "adbusers" ++
          optional config.services.samba.enable config.services.samba.usershares.group ++
          optional config.services.trezord.enable "trezord";
        }
      ];

  root = { config, lib, ... }: {

    services.logind.killUserProcesses = true;

    users.users.root = {
      homeMode = "0700";
      createHome = true;
      home = "/root";
      hashedPasswordFile = with lib; mkIf
        # TODO: disable root password login if sops secret not found!
        (hasAttrByPath
          [ "sops" "secrets" "root-password" ]
          config)
        config.sops.secrets.root-password.path;

      # inherit (config.users.users.vod) openssh;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCwIsdZ2Wz2u1hyQpzDqSwk2x8kmh4Uo0w47eTVQLpIWn+zur9BjlwCWSy5xnRlnu5C8BqBhDF1dl5MeXKakIFiXRPNPtHMfeTe+Q9B0Q1cM5/ZiHM9Du9rdZ6nZRlkjB1t8ShqxVrMRKn6Ed+3yX3DJ/Ab8szxgoO4IDrnJDs4cUvGv7n4XrkESrHddeQfOuik0rZiLu1iw12cyuLQmJWpq8Q5BMHEBeGWvj68D5wHeHLhfK+ZacU8IezqUmPp+ECZLR9vhf3Kel1QZb1s9F2+RUWgbo+KPJSNxSmHJ25kji32M1eVd6cA9BoPqRFzHWISXL7CM52z5Z+E+hyeVmR2jIx9agS9iTLczTO7Hs4lEoFESPmT/FkB0YefIzy17j+8bKItCeZDfmy5M056I/kShZIPp86fM5dmH/PSKngyozKz6MrbBxJkhAlsXmhbGqmHALcy19vEYF/4mbb4gf6gLWUwsho10UvkMybQ2jpsdvGkqJg89hMqFbYKBPN9lAnRoPVlKS7SBBfnLjC9RtHduwvoYHJeXQNaGW1mNCbg1M/WmqghY4BWKTqxCPoraejtFVLjB9DepRAmQg+fZrQYq+Q+A1yHFVTwrxapIseD9Udth+kAsUKbYP3vUsFDlSdFz3U6QWH8TnhwCsRbIvOYptPmc0o3kNQ4buC/vZCP1w== openpgp:0x1F41C323"
        "ssh-rsa AAAAB3NzaC1yc2EAAAABEQAAAgEAuAMvzkrqJipmzH2YYJUkkoPb8NEsF5uqMLJoqzdS7cKbt4I1j6XmIVh/I3zuxtAYgiAScDMsU8dlKZGeaW1lJwDNQyRAM070kEwmwZtu0yppy+ZYQJIdttVoWVMHBOqV2IiHl8r6Ag8yoRsUkGB3yXdpNFrFxCfAoB+Zf9W9yiirlElxAi1E7ccwiBkpZ1cfqraDmbyHdB6yI8YJCTad2y20zcHr6rNgqsypu2NrmuNK6iQ9fsS5jvh2iydIVM3Mw/4HHH8dxAZOpXaS/9xvXu1Yl9mBbG2TBmuDUl/oX9Zvr63xq2rvttoDe6z+ZFUL70xi2Wrg1AxwQeX2XqjcYqpFFpDUAW1VcrB0ZqlPN1OET3cIpjNHtNDHJtnYxpyrNlDsWGLLW8BtLanEmdGOI6PhwhR90igNAYZY8oEEx3L5TeYInoywl9f69jnVVENU0CSoc2m6h4ffWmiITQGmk2Ik9DECraZsvJxMQw4q1WwgrhvgzGRfuHlJXRq7hE+MLF2rBubpGobaK1/apVgQ8vtvRQeiV4Sig/AaZxw7pF1yK9a7XT3DvlcwJXxvjWZF4N5ljh5V5dzLjO+NhI2nTaIx61FchfCGv/vlqKk2SH9djAqZ6cFjSxokvJ9QPxGCoDEK8nu0XjNBSCcnL1R4/7tXKFLvCTaM5nrdO1DPspE= cardno:000F_77033511"
      ];
    };

  };
} // inputs.cells.common.lib.importers.importProfilesRakeleaves {
  src = ./userProfiles;
  inputs = { inherit cell inputs; };
}
