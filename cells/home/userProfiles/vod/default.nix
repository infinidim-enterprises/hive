{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:

{
  imports =
    [
      {
        disabledModules = [
          "services/security/opensnitch.nix"
          # "services/security/pass-secret-service"
        ];
      }
      inputs.cells.nixos.nixosModules.services.security.opensnitch
      # cell.nixosModules.services.security.pass-secret-service
      inputs.cells.nixos.nixosModules.services.x11.window-managers.stumpwm
      # cell.nixosModules.services.x11.remote-display
      # cell.nixosModules.services.networking.zerotierone
    ] ++
    # [ cell.nixosProfiles.desktop.remote-display-host-5-heads ] ++
    (with inputs.cells.nixos.nixosProfiles; [
      desktop.stumpwm
      desktop.chromium-browser
      # desktop.firefox-browser
      hardware.cryptography
    ]) ++
    [
      # inputs.cells.bootstrap.nixosProfiles.core.fonts
    ];

  services.xserver.windowManager.stumpwm.enable = true;

  home-manager.users.vod.imports =
    cell.homeSuites.developer.default ++
    [ ./home ] ++
    [{
      services.xserver.windowManager.stumpwm.confDir = ./dotfiles/stumpwm.d;
      services.xserver.windowManager.stumpwm.enable = true;
    }];

  sops.secrets.vod-password = {
    key = "vod-password";
    sopsFile = ../../../secrects/sops/nixos-common.yaml;
    neededForUsers = true;
  };

  users.users.vod = {
    hashedPasswordFile = config.sops.secrets.vod-password.path;
    # hashedPassword = "$6$VsWUQCau32Oa$tNiMK5LftcuYDRPeACeP/BLikr7tYps/MHDeF3GT0bNRvyEW3PgIXXMzBY5x.FvGO6NprwhDldeFeKBzVQuhI1";
    description = "Никто кроме нас";
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCwIsdZ2Wz2u1hyQpzDqSwk2x8kmh4Uo0w47eTVQLpIWn+zur9BjlwCWSy5xnRlnu5C8BqBhDF1dl5MeXKakIFiXRPNPtHMfeTe+Q9B0Q1cM5/ZiHM9Du9rdZ6nZRlkjB1t8ShqxVrMRKn6Ed+3yX3DJ/Ab8szxgoO4IDrnJDs4cUvGv7n4XrkESrHddeQfOuik0rZiLu1iw12cyuLQmJWpq8Q5BMHEBeGWvj68D5wHeHLhfK+ZacU8IezqUmPp+ECZLR9vhf3Kel1QZb1s9F2+RUWgbo+KPJSNxSmHJ25kji32M1eVd6cA9BoPqRFzHWISXL7CM52z5Z+E+hyeVmR2jIx9agS9iTLczTO7Hs4lEoFESPmT/FkB0YefIzy17j+8bKItCeZDfmy5M056I/kShZIPp86fM5dmH/PSKngyozKz6MrbBxJkhAlsXmhbGqmHALcy19vEYF/4mbb4gf6gLWUwsho10UvkMybQ2jpsdvGkqJg89hMqFbYKBPN9lAnRoPVlKS7SBBfnLjC9RtHduwvoYHJeXQNaGW1mNCbg1M/WmqghY4BWKTqxCPoraejtFVLjB9DepRAmQg+fZrQYq+Q+A1yHFVTwrxapIseD9Udth+kAsUKbYP3vUsFDlSdFz3U6QWH8TnhwCsRbIvOYptPmc0o3kNQ4buC/vZCP1w== openpgp:0x1F41C323" ];
  };
}
