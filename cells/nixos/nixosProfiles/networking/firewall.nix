{ inputs, cell, ... }:

{ lib, config, ... }:

let inherit (lib)
  mkMerge
  mkIf
  mkDefault
  mkForce;
in

mkMerge [
  {
    networking.firewall.enable =
      if config.security.googleOsLogin.enable
      then mkForce true
      else mkDefault true;
    # networking.firewall.allowedTCPPorts = [ 8888 8889 ];
    # networking.firewall.allowedUDPPorts = [ 8888 8889 ];
    networking.firewall.allowPing = mkDefault false;
    networking.firewall.logRefusedConnections = mkDefault false;

    # networking.firewall.extraCommands = ''
    #   # iptables -t nat -A PREROUTING -i eno1 -p tcp --dport 443 -j REDIRECT --to-port 8080
    #   # iptables -t nat -A PREROUTING -i eno1 -p tcp --dport 80 -j REDIRECT --to-port 8080
    # '';
  }
]
