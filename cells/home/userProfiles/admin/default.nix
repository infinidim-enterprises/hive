{ inputs, cell, ... }:

{ config, lib, ... }:
let
  inherit (lib) mkMerge;
in
{
  imports = [
    # (inputs.cells.nixos.nixosProfiles.backups.restic { user = "admin"; extraDirs = [ "tmp" ]; })
  ];

  config = mkMerge [
    {
      home-manager.users.admin.imports =

        cell.homeSuites.developer.default
        ++ cell.homeSuites.wayland
        ++ [
          # inputs.nix-doom-emacs.hmModule

          # ../vod/home/emacs.nix # FIXME: for testing
          ../vod/home/gitconfig.nix # FIXME: for testing

          cell.homeProfiles.security.gpg

          ({ pkgs, ... }: {
            services.gpg-agent.pinentryPackage = pkgs.pinentry-gnome3;
            home.packages = [ pkgs.dconf ];
          })
        ];
    }

    {
      users.users.admin.extraGroups = [ "wheel" ];
      programs.dconf.enable = true;
    }

    {
      users.users.admin = {
        # NOTE: cannot have it as a sops secret, since this user gets to be in bootstrap
        hashedPassword = "$6$hMM0iey5Ypc0Mpow$ZU64D7qWfnU/Z088CSSgYzPur.Ele8U6XcxRssNCvfHvWhCtarrTe5dd432sCwl3wooj.PcwAEkiAZyKh0I1X0";
        description = "Administrator";
        isNormalUser = true;
        uid = 10000;
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCwIsdZ2Wz2u1hyQpzDqSwk2x8kmh4Uo0w47eTVQLpIWn+zur9BjlwCWSy5xnRlnu5C8BqBhDF1dl5MeXKakIFiXRPNPtHMfeTe+Q9B0Q1cM5/ZiHM9Du9rdZ6nZRlkjB1t8ShqxVrMRKn6Ed+3yX3DJ/Ab8szxgoO4IDrnJDs4cUvGv7n4XrkESrHddeQfOuik0rZiLu1iw12cyuLQmJWpq8Q5BMHEBeGWvj68D5wHeHLhfK+ZacU8IezqUmPp+ECZLR9vhf3Kel1QZb1s9F2+RUWgbo+KPJSNxSmHJ25kji32M1eVd6cA9BoPqRFzHWISXL7CM52z5Z+E+hyeVmR2jIx9agS9iTLczTO7Hs4lEoFESPmT/FkB0YefIzy17j+8bKItCeZDfmy5M056I/kShZIPp86fM5dmH/PSKngyozKz6MrbBxJkhAlsXmhbGqmHALcy19vEYF/4mbb4gf6gLWUwsho10UvkMybQ2jpsdvGkqJg89hMqFbYKBPN9lAnRoPVlKS7SBBfnLjC9RtHduwvoYHJeXQNaGW1mNCbg1M/WmqghY4BWKTqxCPoraejtFVLjB9DepRAmQg+fZrQYq+Q+A1yHFVTwrxapIseD9Udth+kAsUKbYP3vUsFDlSdFz3U6QWH8TnhwCsRbIvOYptPmc0o3kNQ4buC/vZCP1w== openpgp:0x1F41C323"
          "ssh-rsa AAAAB3NzaC1yc2EAAAABEQAAAgEAuAMvzkrqJipmzH2YYJUkkoPb8NEsF5uqMLJoqzdS7cKbt4I1j6XmIVh/I3zuxtAYgiAScDMsU8dlKZGeaW1lJwDNQyRAM070kEwmwZtu0yppy+ZYQJIdttVoWVMHBOqV2IiHl8r6Ag8yoRsUkGB3yXdpNFrFxCfAoB+Zf9W9yiirlElxAi1E7ccwiBkpZ1cfqraDmbyHdB6yI8YJCTad2y20zcHr6rNgqsypu2NrmuNK6iQ9fsS5jvh2iydIVM3Mw/4HHH8dxAZOpXaS/9xvXu1Yl9mBbG2TBmuDUl/oX9Zvr63xq2rvttoDe6z+ZFUL70xi2Wrg1AxwQeX2XqjcYqpFFpDUAW1VcrB0ZqlPN1OET3cIpjNHtNDHJtnYxpyrNlDsWGLLW8BtLanEmdGOI6PhwhR90igNAYZY8oEEx3L5TeYInoywl9f69jnVVENU0CSoc2m6h4ffWmiITQGmk2Ik9DECraZsvJxMQw4q1WwgrhvgzGRfuHlJXRq7hE+MLF2rBubpGobaK1/apVgQ8vtvRQeiV4Sig/AaZxw7pF1yK9a7XT3DvlcwJXxvjWZF4N5ljh5V5dzLjO+NhI2nTaIx61FchfCGv/vlqKk2SH9djAqZ6cFjSxokvJ9QPxGCoDEK8nu0XjNBSCcnL1R4/7tXKFLvCTaM5nrdO1DPspE= cardno:000F_77033511"
        ];
      };
    }
  ];
}
