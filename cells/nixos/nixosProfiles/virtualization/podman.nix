{ inputs, cell, ... }:

{ pkgs, ... }:
{
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
  virtualisation.podman.autoPrune.enable = true;
  virtualisation.podman.dockerSocket.enable = true;
  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

  environment.systemPackages = with pkgs; [
    docker-client
    podman-compose
    podman-tui
  ];
}
