{ inputs, cell, ... }:

{ lib, config, ... }:

{
  services.openssh = with lib; {
    enable = mkDefault true;
    openFirewall = mkDefault true;
    allowSFTP = mkDefault true;
    settings = {
      LogLevel = "INFO";
      KbdInteractiveAuthentication = false;
      # https://github.com/NixOS/nixpkgs/issues/234683
      # permitRootLogin = mkDefault "no";
      PasswordAuthentication = false;
      PermitRootLogin = mkDefault "no";
      X11Forwarding = mkDefault true;
    };
    extraConfig = ''
      StreamLocalBindUnlink yes
      X11UseLocalhost yes
      ClientAliveInterval 180
      TCPKeepAlive yes
      LoginGraceTime 120
      StrictModes yes
      IgnoreRhosts yes
      HostbasedAuthentication no
      PermitEmptyPasswords no
      PubkeyAuthentication yes
      PrintLastLog yes
      AllowAgentForwarding yes
      AcceptEnv *
    '';
    hostKeys = mkDefault [
      {
        bits = 4096;
        openSSHFormat = true;
        comment = "Default - ${config.networking.hostName}";
        path = "/etc/ssh/ssh_host_rsa_key";
        rounds = 100;
        type = "rsa";
      }

      {
        bits = 4096;
        openSSHFormat = true;
        comment = "sops/age/colmena - for ${config.networking.hostName}";
        path = "/etc/ssh/ssh_host_ed25519_key";
        rounds = 100;
        type = "ed25519";
      }
    ];

  };
  # systemd.services.nix-daemon.environment.SSH_AUTH_SOCK = "/run/user/1000/ssh-XXXXXXUdcI9y/agent.1682306";
}
