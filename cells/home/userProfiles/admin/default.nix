{ inputs, cell, ... }:

{ config, lib, ... }:
let
  inherit (lib) mkMerge;
in
{
  imports = [ inputs.cells.nixos.nixosProfiles.hardware.cryptography ];
  home-manager.users.admin.imports = [
    ({ pkgs, ... }: {
      services.gpg-agent.pinentryPackage = pkgs.pinentry-tty;
    })
  ];
} //
(lib.mkMerge [
  { users.users.admin.extraGroups = [ "wheel" ]; }
  {
    users.users.admin = {
      hashedPassword = "$6$hMM0iey5Ypc0Mpow$ZU64D7qWfnU/Z088CSSgYzPur.Ele8U6XcxRssNCvfHvWhCtarrTe5dd432sCwl3wooj.PcwAEkiAZyKh0I1X0";
      description = "Administrator";
      isNormalUser = true;
      uid = 10000;
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCwIsdZ2Wz2u1hyQpzDqSwk2x8kmh4Uo0w47eTVQLpIWn+zur9BjlwCWSy5xnRlnu5C8BqBhDF1dl5MeXKakIFiXRPNPtHMfeTe+Q9B0Q1cM5/ZiHM9Du9rdZ6nZRlkjB1t8ShqxVrMRKn6Ed+3yX3DJ/Ab8szxgoO4IDrnJDs4cUvGv7n4XrkESrHddeQfOuik0rZiLu1iw12cyuLQmJWpq8Q5BMHEBeGWvj68D5wHeHLhfK+ZacU8IezqUmPp+ECZLR9vhf3Kel1QZb1s9F2+RUWgbo+KPJSNxSmHJ25kji32M1eVd6cA9BoPqRFzHWISXL7CM52z5Z+E+hyeVmR2jIx9agS9iTLczTO7Hs4lEoFESPmT/FkB0YefIzy17j+8bKItCeZDfmy5M056I/kShZIPp86fM5dmH/PSKngyozKz6MrbBxJkhAlsXmhbGqmHALcy19vEYF/4mbb4gf6gLWUwsho10UvkMybQ2jpsdvGkqJg89hMqFbYKBPN9lAnRoPVlKS7SBBfnLjC9RtHduwvoYHJeXQNaGW1mNCbg1M/WmqghY4BWKTqxCPoraejtFVLjB9DepRAmQg+fZrQYq+Q+A1yHFVTwrxapIseD9Udth+kAsUKbYP3vUsFDlSdFz3U6QWH8TnhwCsRbIvOYptPmc0o3kNQ4buC/vZCP1w== openpgp:0x1F41C323" ];
    };
  }
])
